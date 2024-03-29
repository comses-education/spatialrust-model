FROM comses/osg-julia:1.7.3

LABEL maintainer="CoMSES Net <support@comses.net>"

ENV JULIA_DEPOT_PATH=/opt/julia/share/julia

WORKDIR /code
COPY install.jl Project.toml /code/
COPY src/SpatialRust.jl /code/src/
RUN chmod -R a+rX /opt/julia/share/julia && \
    mkdir -p /code/results

RUN julia install.jl 
# split up the COPYs so that modification of anything that doesn't affect the `julia install.jl` command doesn't force a
# full container rebuild
COPY . /code
