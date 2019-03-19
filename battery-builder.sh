#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
PURP='\033[0;35m'
figlet "battery   pack"
figlet "builder   1 . 0"

echo
echo "Lets gather some info and help you build a battery pack." 
echo "You will enter some into about your cells and the final voltage and capacity of the pack you are planning to build."
echo
echo "For the purpose of this script, 'pack' refers to the final assembled battery you are building,"
echo "'cell' refers to the 18650, pouch, prismatic, etc you are using to build the pack."
echo
echo "What is the nominal voltage of the cell?"
read CELL_VOLTAGE
echo
echo "What is the capacity of the cell in Ah?"
read CELL_CAPACITY
echo
echo "What is the maximum continuous discharge of the cell in A?"
read CELL_DISCHARGE
echo
echo "What is the target final voltage of the pack you are building?"
read TARGET_VOLTAGE
echo
echo "What is the target capacity of the pack you are building in Ah?"
read TARGET_CAPACITY
echo
echo "How many amps are continuously being drawn from the pack?"
read AMP_DRAW
echo
echo "What is the cost of each cell?"
read CELL_COST
echo

SERIES=$(bc <<< "scale=0;$TARGET_VOLTAGE/$CELL_VOLTAGE")
REAL_VOLTAGE=$(bc <<< "scale=2;$SERIES*$CELL_VOLTAGE")
PARALLEL=$(bc <<< "scale=0;$TARGET_CAPACITY/$CELL_CAPACITY")
REAL_CAPACITY=$(bc <<< "scale=2;$PARALLEL*$CELL_CAPACITY")
MAX_AMP_DRAW_PACK=$(bc <<< "scale=2;$PARALLEL*$CELL_DISCHARGE")
SAFTEY_FACTOR=$(bc <<< "scale=2;$MAX_AMP_DRAW_PACK/$AMP_DRAW")
RUN_TIME=$(bc <<< "scale=2;$REAL_CAPACITY/$AMP_DRAW")
TOTAL_CELLS=$(bc <<< "scale=0;$PARALLEL*$SERIES")
TOTAL_COST=$(bc <<< "scale=2;$TOTAL_CELLS*$CELL_COST")
RUN_TIME_MINS=$(bc <<< "scale=0;$RUN_TIME*60")
SET_FACTOR=1.4


if (( $(echo "$MAX_AMP_DRAW_PACK > $AMP_DRAW" |bc -l) ));
then
	printf "\n For a pack with a target voltage of $TARGET_VOLTAGE V, ${PURP}you will need $SERIES cells in series.${NC}"
	printf "\n This will yeild a pack with a ${PURP}real voltage of $REAL_VOLTAGE V.${NC}"
	echo
	printf "\n For a pack with a target capacity of $TARGET_CAPACITY Ah, ${PURP}you will need $PARALLEL cells in parallel.${NC}"
	printf "\n This will yeild a pack with a ${PURP}real capacity of $REAL_CAPACITY Ah.${NC}"
	echo
	printf "\n The max continuous amp draw from this pack ${PURP}will be $MAX_AMP_DRAW_PACK A.${NC}"
	echo
	printf "\n Your pack has a ${PURP}discharge saftey factor of $SAFTEY_FACTOR.${NC}"
	printf "\n This is the total continous discharge in amps of your pack divided by the amps continuously drawn from the pack."

	if (( $(echo "$SAFTEY_FACTOR > $SET_FACTOR" |bc -l) ));
	then
		printf "\n ${GREEN}This is a safe pack, good job.${NC}"
		echo
	else
		printf "\n ${RED}This is not a safe pack. You should have a discharge saftey factor of at least 1.4.${NC}"
		echo
	fi

	echo
	printf "\n You will need a ${PURP}total of $TOTAL_CELLS cells ${NC}at a cost of ${GREEN}$ $TOTAL_COST${NC} for the cells."
	echo
	printf "\n ${GREEN}You have built a $SERIES"s"$PARALLEL"p" pack with a nominal voltage of $REAL_VOLTAGE V,${NC}"
	printf "\n ${GREEN}a capacity of $REAL_CAPACITY Ah, and a max continuous discharge of $MAX_AMP_DRAW_PACK A.${NC}"
	printf "\n ${GREEN}Your pack should last for $RUN_TIME_MINS minutes at the maximum continuous discharge rate.${NC}"
else
	printf "\n ${RED}This cell is insufficient for your needs with this pack configuration.${NC}"
	printf "\n ${RED}The max continuous amp draw from this pack will be $MAX_AMP_DRAW_PACK A which is less than your requirement of $AMP_DRAW.${NC}"
	printf "\n ${RED}Either pick a cell with a higher continuous max discharge or increase the number of cells in PARALLEL from $PARALLEL cells.${NC}"
fi


