
[PlanarLarvae.jl](https://gitlab.pasteur.fr/nyx/planarlarvae.jl) documentation.

```@contents
```

# API

# Top-level module

```@docs
PlanarLarvae.Formats
```

```@docs
PlanarLarvae.Formats.PreloadedFile
```

## Reading files

```@docs
PlanarLarvae.Formats.load
```

```@docs
PlanarLarvae.Formats.preload
```

```@docs
PlanarLarvae.Formats.load!
```

```@docs
PlanarLarvae.Formats.unload!
```

## Helpers

```@docs
PlanarLarvae.Formats.guessfileformat
```

```@docs
PlanarLarvae.Formats.labelledfiles
```

```@docs
PlanarLarvae.Formats.from_mwt
```

## Getters

```@docs
PlanarLarvae.Formats.getmetadata
```

```@docs
PlanarLarvae.Formats.getlabels
```

```@docs
PlanarLarvae.Formats.getnativerepr
```

```@docs
PlanarLarvae.Formats.gettimeseries
```

```@docs
PlanarLarvae.Formats.getrun
```

```@docs
PlanarLarvae.Formats.getdependencies
```

```@docs
PlanarLarvae.Formats.getdependencies!
```

# Reading/writing files

```@docs
read_chore_files
```
```@docs
read_trxmat
```
```@docs
read_fimtrack
```
```@docs
PlanarLarvae.Datasets.from_json_file
```
```@docs
PlanarLarvae.Datasets.to_json_file
```

## Support functions

```@docs
read_outline
```
```@docs
read_spine
```
```@docs
read_trxmat_var
```
```@docs
find_chore_files
```
```@docs
find_trxmat_file
```
```@docs
PlanarLarvae.Datasets.encodelabels
```
```@docs
PlanarLarvae.Datasets.decodelabels
```
```@docs
PlanarLarvae.Datasets.mergelabels!
```
```@docs
PlanarLarvae.Datasets.setdefaultlabel!
```
```@docs
PlanarLarvae.Datasets.expand!
```

```@docs
PlanarLarvae.Formats.setdefaultlabel!
```

# Data collections

```@docs
PlanarLarvae.Datasets.Dataset
```
```@docs
PlanarLarvae.Datasets.Run
```
```@docs
PlanarLarvae.Datasets.Track
```

## Type aliases

```@docs
PlanarLarvae.Runs
```
```@docs
PlanarLarvae.Larvae
```
```@docs
PlanarLarvae.TimeSeries
```
```@docs
LarvaID
```
```@docs
PlanarLarvae.Time
```

## Support functions

```@docs
eachtimeseries
```
```@docs
eachstate
```
```@docs
map′
```
```@docs
zip′
```
```@docs
filterlarvae
```

# Data records

```@docs
Spine
```
```@docs
Outline
```
```@docs
BehaviorTags
```
```@docs
Records
```
```@docs
outline
```
```@docs
spine
```
```@docs
geometry
```
```@docs
SpineGeometry
```
```@docs
OutlineGeometry
```
```@docs
vertices′
```

## Support types and functions

```@docs
RawOutline
```
```@docs
Outlinef
```
```@docs
RawSpine
```
```@docs
Spinef
```
```@docs
Path
```
```@docs
tmin
```
```@docs
xmin
```
```@docs
bounds
```
```@docs
centroid
```
```@docs
larvatrack
```
```@docs
derivedtype
```

# Index

```@index
```
