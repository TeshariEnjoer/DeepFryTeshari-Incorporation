// from /datum/controller/subsystem/train_controller/proc/start_moving(), /datum/controller/subsystem/train_controller/ss, force
#define COMSIG_TRAIN_BEGIN_MOVING "train_begin_moving"
// from /datum/controller/subsystem/train_controller/proc/stop_moving(), /datum/controller/subsystem/train_controller/ss
#define COMSIG_TRAIN_STOP_MOVING "train_stop_moving"
// from /datum/controller/subsystem/train_controller/proc/check_start(), /datum/controller/subsystem/train_controller/ss
#define COMSIG_TRAIN_TRY_MOVE "train_try_move"
	#define COMPONENT_BLOCK_TRAIN_MOVEMENT (1 << 2) //stops train from start moving
// from /obj/machinery/computer/trainstation_control/proc/unlock_station(), /datum/controller/subsystem/train_controller/ss, /obj/machinery/computer/trainstation_control/computer, station
#define COMSIG_TRAINSTATION_UNLOCKED "trainstation_unlocked"
// from /datum/controller/subsystem/train_controller/proc/load_station(), /datum/controller/subsystem/train_controller/ss, loaded_station
#define COMSIG_TRAINSTATION_LOADED "trainstation_loaded"
// from /datum/controller/subsystem/train_controller/proc/unload_station(), /datum/controller/subsystem/train_controller/ss, unloaded_station
#define COMSIG_TRAINSTATION_UNLOADED "trainstation_unloaded"
