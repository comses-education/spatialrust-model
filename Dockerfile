FROM comses/osg-julia:1.7.3

WORKDIR /code
COPY . /code

RUN mkdir -p /code/results && julia install.jl 

# && \
    # chmod -R go+rX /opt/julia/share/julia /code

