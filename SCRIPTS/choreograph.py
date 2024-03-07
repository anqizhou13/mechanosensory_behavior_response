def find_nearest(array, value):
    import numpy as np
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx

def timeSeries(input,output,name,paths,window,colors):
    import time
    import glob
    import os
    import numpy as np
    import time
    import pandas as pd
    from tqdm import tqdm
    import matplotlib.pyplot as plt
    from scipy.signal import savgol_filter

    col_names = [
        'index',
        't',
        'Number',
        'Good number',
        'Persistence',
        'Speed',
        'Angular speed',
        'Length',
        'Instantaneous length',
        'Width',
        'Instantaneous width',
        'Aspect',
        'Instantaneous aspect',
        'Midline',
        'Kink',
        'Bias',
        'Curve',
        'Consistency',
        'X',
        'Y',
        'X velocity',
        'Y velocity',
        'Orientation',
        'Crab',
    ]

   
    if not os.path.exists('{}/{}'.format(output,name)):
        os.makedirs('{}/{}'.format(output,name))

    output_files = []

    for path in paths:
        startTime = time.time()
        chor_files = glob.glob("{}/{}/**/**.dat".format(input,path), recursive = True)

        file_name = str.split(path,'/')
        output_file = "{}/{}_choreograph_{}s_{}s.csv".format(output,file_name[0],window[0],window[1])

        output_files.append(output_file)

        if os.path.exists(output_file) == True:
            print("Genotype alreay processed, skipping {}".format(path))
            continue
        print(" Processing {}...".format(path))

        data = []
        # for all choreograph files in a genotype
        print('{} Choreograph files found'.format(len(chor_files)))
        for chor_file in tqdm(chor_files):
            # open the choreograph file
            f = open(chor_file, "r")
            f = f.read()
            # break down line
            f = f.split("\n")

            # convert each line from string to array
            for i in range(len(f)-1):
                if len(f[i].split()) == len(col_names):
                    data.append(np.array(f[i].split(),dtype = float))

        # stack array by larva
        data = np.vstack(data)
        # sort by timepoints
        data = data[data[:,0].argsort()]

        # retrieve time vector
        t = np.linspace(window[0],window[1],(window[1]-window[0])*5)

        # instantiate lists to store average of larvae
        n = []
        data_all = []
        
        for i in tqdm(range(len(t)-1)):
            # for each time point, subset from data all larvae tracked at that time
            start = find_nearest(data[:,0], t[i])
            end = find_nearest(data[:,0],t[i+1])
            temp = data[start:end,:]
            # compute average
            value = np.nanmean(temp,axis =0)
            data_all.append(value)
            n.append(len(temp))
        del data

        # make pandas dataframe
        df = pd.DataFrame(data_all,columns = col_names)
        df.to_csv(output_file)
        del df,data_all,n

        endTime = time.time()
        runTime = endTime - startTime
        print(" Probability file saved, runtime {} seconds ".format(runTime))

    # for visualizations

    df = []
    for output_file in output_files:
        df.append(np.array(pd.read_csv(output_file)))
    df = np.array(df)
    df = np.transpose(df,(0,2,1))

    # for uniform kernel smoothing data
    #kernel_mean = np.ones(30) / 30
    #kernel_sem = np.ones(10) / 10

    print('Visualizing...')

    plt.rcParams['font.sans-serif'] = "Arial"
    plt.rcParams['font.family'] = "sans-serif"

    for i,col_name in enumerate(col_names):

        fig,ax = plt.subplots(2,1,figsize=(2,4), dpi=300)

        for j,__ in enumerate(paths):
            vector = np.array(pd.Series(df[j][i]).rolling(5, min_periods=1).mean())
            # normalize with the average of 30-50s window
            baseline = np.nanmean(vector[15:250,])
            vector_norm = vector-baseline
            ax[0].plot(np.linspace(window[0],window[1],len(df[j][0])),vector,color = colors[j])
            ax[1].plot(np.linspace(window[0],window[1],len(df[j][0])),vector_norm,color = colors[j])     

        ax[0].set_title(col_name)
        ax[1].set_title('Normalized {}'.format(col_name))
        ax[1].set_xlabel('Seconds (s)')

        ax[0].spines.right.set_visible(False)
        ax[0].spines.top.set_visible(False)
        ax[1].spines.right.set_visible(False)
        ax[1].spines.top.set_visible(False)

        plt.tight_layout()
        plt.savefig('{}/{}/{}.svg'.format(output,name,col_name), format='svg')
        plt.savefig('{}/{}/{}.pdf'.format(output,name,col_name), format='pdf')

        del fig,ax

