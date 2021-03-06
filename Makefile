# customize via `% make build OSG_USERNAME=<your-osg-username>` e.g., `% make build OSG_USERNAME=amelie`

OSG_USERNAME := ${USER}
MODEL_NAME := spatialrust
ENTRYPOINT_SCRIPT_EXECUTABLE := julia
ENTRYPOINT_SCRIPT := ParameterRuns.jl
OSG_SUBMIT_TEMPLATE := scripts/submit.template
OSG_SUBMIT_FILENAME := scripts/${MODEL_NAME}.submit
OSG_JOB_SCRIPT := job-wrapper.sh

SINGULARITY_DEF = Singularity.def
CURRENT_VERSION = v2
SINGULARITY_IMAGE_NAME = ${MODEL_NAME}-${CURRENT_VERSION}.sif

all: build

$(SINGULARITY_IMAGE_NAME):
	singularity build --fakeroot ${SINGULARITY_IMAGE_NAME} ${SINGULARITY_DEF}

$(OSG_SUBMIT_FILENAME): $(OSG_SUBMIT_TEMPLATE)
	SINGULARITY_IMAGE_NAME=${SINGULARITY_IMAGE_NAME} \
	OSG_USERNAME=${OSG_USERNAME} \
	ENTRYPOINT_SCRIPT_EXECUTABLE=${ENTRYPOINT_SCRIPT_EXECUTABLE} \
	ENTRYPOINT_SCRIPT=${ENTRYPOINT_SCRIPT} \
	envsubst < ${OSG_SUBMIT_TEMPLATE} > ${OSG_SUBMIT_FILENAME}

build: $(SINGULARITY_DEF) $(SINGULARITY_IMAGE_NAME) $(OSG_SUBMIT_FILENAME)
	docker build -t comses/${MODEL_NAME}:${CURRENT_VERSION} .

.PHONY: clean deploy

clean:
	rm -f ${SINGULARITY_IMAGE_NAME} ${OSG_SUBMIT_FILENAME} *~

deploy: build
	echo "IMPORTANT: This command assumes you have created an ssh alias in your ~/.ssh/config named 'osg' that connects to your OSG connect node"
	echo "Copying singularity image to osg:/public/${OSG_USERNAME}"
	rsync -avzP ${SINGULARITY_IMAGE_NAME} osg:/public/${OSG_USERNAME}
	echo "Creating ${MODEL_NAME} folder in /home/${OSG_USERNAME}"
	ssh ${OSG_USERNAME}@osg mkdir -p ${MODEL_NAME}
	echo "Copying submit filename, job script, and entrypoint scripts to /home/${OSG_USERNAME}/${MODEL_NAME}"
	rsync -avzP scripts/ osg:${MODEL_NAME}/
