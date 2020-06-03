#!/bin/bash
# framework(dataDetailsFile,                % File with details from the dataset (no arguments)
#           loadDatasetFile,                % File with the function to load dataset (arg1 - if is train; arg2 - dataDetails)
#           evaluationTestFile,             % File with the function to test the model created (arg1 - net; arg2 - testData; arg3 - ?)
#           randomSeed,                     % Random seed used to set the random values generation (integer)
#           isToDeleteIntermediateNetFiles, % If the intermediate train files created shold be deleted (true - yes)
#           trainDetailsFile,               % File with details for the training
#           setupNetFile,                   % File with the function to create the net for training
#           resultDir)                      % String where the file will be saved

DATA_DETAILS_FILE=''                            # It is the first argument
LOAD_DATASET_FILE='';                           # It is the second argument
EVALUATION_TEST_FILE='';                        # It is the third argument
SEED=$(($RANDOM));                              # -s
DELETE_INTERMEDIATE_NET_FILES=false;            # -d
TRAIN_DETAILS_FILE='./details/trainDetails.m';  # -t
NET_FILE_SETUP='./details/setupNet.m';           # -n
OUTPUT_LOG_FILE='default+';                     # -o

HELP=false;                                     # -h

function help_print() {
    echo "Command help:"
    echo "    arg1: matlab file that contains the details of the dataset"
    echo "    arg2: matlab file that contains the load dataset function"
    echo "    arg3: matlab file that contains the evaluation of the test function"
    echo "       -d to use delete the intermediate net files"
    echo "       -n FILE matlab file that contains the construction of the network that will be trained (default = './details/setupNet.m')"
    echo "       -o FILE log file name that will be used to save the train info and to create the log dir (default = composition of the configurations)"
    echo "       -s SEED integer number that will be used as seed for the pseudo-random number creation"
    echo "       -t FILE matlab file that contains the details of the training (default = './details/trainDetails.m')"
    echo ""
    echo "Usage: ./run.sh arg1 arg2 arg3 [options [-d] [-n FILE] [-o FILE] [-s SEED] [-t FILE]]"
}   # end of help_print

args=$(getopt -l "delete" -l "setup_net:" -l "output_log" -l "seed:" -l "train_details:" -l "help" -o "dn:o:s:t:h" -- "$@")

eval set -- "$args"

for a in $args; do
    case "$a" in
        --)
            # No more options left.
            shift
            break
            ;;
        -d|--delete)
                DELETE_INTERMEDIATE_NET_FILES=true
                ;;
        -n|--setup_net)
                NET_FILE_SETUP=$2
                ;;
        -o|--output_log)
                OUTPUT_LOG_FILE=$2
                ;;
        -s|--seed)
                SEED=$2
                ;;
        -t|--train_details)
                TRAIN_DETAILS_FILE=$2
                ;;
        -h|--help)
                help_print
                exit 0
                ;;
    esac
    shift
done

DATA_DETAILS_FILE=$1;
LOAD_DATASET_FILE=$2;
EVALUATION_TEST_FILE=$3;

if [ "$DATA_DETAILS_FILE" = '' -o "$LOAD_DATASET_FILE" = '' -o "$EVALUATION_TEST_FILE" = '' -o "$4" != '' ]; then
    echo "Invalid arguments. It is necessary only one argument."
    help_print
    exit 0
fi

echo "Used values:"
echo "            Data Details file = '$DATA_DETAILS_FILE'"
echo "   Load dataset function file = '$LOAD_DATASET_FILE'"
echo "  Evaluation of the test file = '$EVALUATION_TEST_FILE'"
echo "                    Seed used = $SEED"
echo "    Delete intermediate files = $DELETE_INTERMEDIATE_NET_FILES"
if [ $NET_FILE_SETUP = './setups/setupVggNet.m' ]; then
    echo "          File with net setup = '$NET_FILE_SETUP'"
else
    echo "          File with net setup = './setups/setupVggNet.m' [default]"
fi
if [ $TRAIN_DETAILS_FILE = './setups/trainSetup.m' ]; then
    echo "      File with train details = '$TRAIN_DETAILS_FILE'"
else
    echo "      File with train details = './setups/trainSetup.m' [default]"
fi
LOG_FILE="./results/"
if [ $OUTPUT_LOG_FILE = 'default+' ]; then
    NET_FILE_SETUP_PROCESSED="${NET_FILE_SETUP//'./'/}";
    NET_FILE_SETUP_PROCESSED="${NET_FILE_SETUP_PROCESSED//'/'/'-'}";
    NET_FILE_SETUP_PROCESSED="${NET_FILE_SETUP_PROCESSED//'.m'/}";

    DATA_DETAILS_FILE_PROCESSED="${DATA_DETAILS_FILE//'./'/}";
    DATA_DETAILS_FILE_PROCESSED="${DATA_DETAILS_FILE_PROCESSED//'/'/'-'}";
    DATA_DETAILS_FILE_PROCESSED="${DATA_DETAILS_FILE_PROCESSED//'.m'/}";

    LOAD_DATASET_FILE_PROCESSED="${LOAD_DATASET_FILE//'./'/}";
    LOAD_DATASET_FILE_PROCESSED="${LOAD_DATASET_FILE_PROCESSED//'/'/'-'}";
    LOAD_DATASET_FILE_PROCESSED="${LOAD_DATASET_FILE_PROCESSED//'.m'/}";

    EVALUATION_TEST_FILE_PROCESSED="${EVALUATION_TEST_FILE//'./'/}";
    EVALUATION_TEST_FILE_PROCESSED="${EVALUATION_TEST_FILE_PROCESSED//'/'/'-'}";
    EVALUATION_TEST_FILE_PROCESSED="${EVALUATION_TEST_FILE_PROCESSED//'.m'/}";

    TRAIN_DETAILS_FILE_PROCESSED="${TRAIN_DETAILS_FILE//'./'/}";
    TRAIN_DETAILS_FILE_PROCESSED="${TRAIN_DETAILS_FILE_PROCESSED//'/'/'-'}";
    TRAIN_DETAILS_FILE_PROCESSED="${TRAIN_DETAILS_FILE_PROCESSED//'.m'/}";

    LOG_FILE+="saida"
    LOG_FILE+=$SEED
    LOG_FILE+="_$DATA_DETAILS_FILE_PROCESSED"
    LOG_FILE+="_$LOAD_DATASET_FILE_PROCESSED"
    LOG_FILE+="_$EVALUATION_TEST_FILE_PROCESSED"
    LOG_FILE+="_$NET_FILE_SETUP_PROCESSED"
    LOG_FILE+="_$TRAIN_DETAILS_FILE_PROCESSED"
    LOG_FILE+=".log"
else
    LOG_FILE+=$OUTPUT_LOG_FILE
fi

if [ ! -d "./results" ]; then
    mkdir results;
fi

LOG_DIR=$LOG_FILE
LOG_DIR+='_dir'

echo -e "\nRunning the code and directing the log to: $LOG_FILE."

# randomSeed, dataDetailsFile, trainDetailsFile, setupNetFile, deleteIntermediateNetFiles, resultDir)
echo "Code to run: framework('"$DATA_DETAILS_FILE"', '"$LOAD_DATASET_FILE"', '"$EVALUATION_TEST_FILE"', "$SEED", "$DELETE_INTERMEDIATE_NET_FILES", '"$TRAIN_DETAILS_FILE"', '"$NET_FILE_SETUP"', '"$LOG_DIR"')";
nohup matlab -nodesktop -nosplash -r "framework('"$DATA_DETAILS_FILE"', '"$LOAD_DATASET_FILE"', '"$EVALUATION_TEST_FILE"', "$SEED", "$DELETE_INTERMEDIATE_NET_FILES", '"$TRAIN_DETAILS_FILE"', '"$NET_FILE_SETUP"', '"$LOG_DIR"'); quit;" > $LOG_FILE </dev/null &
