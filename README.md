# HitLCSwHDMATLABversion
Contains a framework for running Human-in-the-Loop Control Synthesis with Hybrid Distance written in the Matlab language.

## Configuration Instructions
To run the code a working and licensed installation of Matlab is required. To the authors knowledge no specific version is needed.

## Installation Instructions
Clone/download the included files. No further installation required.

## Operating Instructions
Run the file mainv3.m. At prompts in the command line, input desired values from given multiple choice list by writing directly in  the command line.

## Copyright/License
This code is open for anyone to use. If the code is used for publication purposes the author asks to be acknowledged in said publication.

## Contact Info
Author: Sofie Ahlberg, sofa@kth.se

## Acknowledgement
Some of the code is based on work by Alexandros Nikou as acknowledged in the specific files.

## Known Bugs
There are no known bugs.

## News
The work with this framework is ongoing. Current work is aimed at
1) Extending test functionality to verify included functions
2) Refactoring the framework to achieve cleaner code
3) Improving documentation

## File Manifest (Updated last: 2021-03-10 at 11:53):
- BWTS
	- cartesian_product.m
	- product.m
	- product2.m
- environment
	- containedIn.m
	- env1.m
	- env2.m
	- env3.m
- hardsoftupd
	- hardConVio.m
	- humanInput.m
	- humanInput2.m
	- humaninputoptions.m
	- learnh.m
	- setUpCurr.m
	- timedQd.m
	- timeMember.m
- logs
	- logtimes03010947.txt
	- logtimes03011602.txt
- MIC
	- Copy_of_realDistances.m
	- currentStateCalc.m
	- easyControl.m
	- easyCurr.m
	- init4p.m
	- neighboors.m
	- realDistances.m
	- rhofunc.m
	- simEvo.m
-path
	- foundPath.m
	- graphSearch.m
	- plotPath2.m
	- taProject.m
	- wtsProject.m
- TAhd
	- hybridTA.m
	- hybridTAsoftandhard.m
	- TAhd_demand.m
	- TAhd_demand2.m
- TS
	- constraint_general_joint.m
	- constraints_general.m
	- constraints_general_lin.m
	- constraints_specific.m
	- constraints_specific_lin.m
	- Time_demand.m
	- Transition_control.m
	- TS_construction.m
	- WTS_simpleconstruction.m
- visualization
	- arrow.m
	- arrow_bend.m
	- Copy_of_truepath.m
	- fastfig.m
	- onlineRun.m
	- partition_viz.m
	- partition_viz_simple.m
	- partition_vizz.m
	- plotPath.m
	- quiverTS.m
	- truepath.m
	- TS_viz.m
	- WTS_plot.m
	- WTS_plot_single.m
- after gca.ps
- before gca.ps
- mainv3.m
- README.md
- systevolution.m
- TestClass.m


