#ifndef _FSM_H
#define _FSM_H

#define STATE_Off 0
#define STATE_On 1

extern int state;
extern int onoff_pressed;

void sm_trigger();
void sm_switch(int new_state);

#endif
