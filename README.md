Glassware
=========

EntityDB looking glass

## Installation

Firstly clone the repository with:

```bash
git clone https://github.com/Community-Run-eXperimental-Network/Glassware
```

Then run:

```bash
cd Glassware/
dub build
```

You should then have an executable binary called `glassware`

## Usage

There are quite a number of routes already, below is an example usage:

```
>>> requests.get("http://[::]:8888/api/routes/list?network=gustav").json()
{'status': {'error': 1, 'detail': 'NETWORK_ERROR'}}
```
