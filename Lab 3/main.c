#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/address_map_arm.h"
#include "./drivers/inc/int_setup.h"

//Section 1: Slider switches and LEDs
//int main() {
//	
//	while(1) {
//		write_LEDs_ASM(read_slider_switches_ASM());
//	}
//	return 0;
//
//}


//Sample program for HEX displays driver
//int main() {
//	HEX_flood_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
//
//	return 0;
//}


Section 2: Test program for HEX display and push buttons
int main() {
	/*Flood HEX4 and HEX5*/
	HEX_flood_ASM(HEX4|HEX5);
	/*We clear the remaining HEX displays to make sure they are cleared before we write to them*/
	HEX_clear_ASM(HEX0|HEX1|HEX2|HEX3);
	while(1){
		/*Slider states dictate the number we ultimately display on the screen*/
		/*512 maps to slider no.9 which simply clears every HEX display save for 4 and 5*/
		int sliderSwitch = read_slider_switches_ASM();
		if (sliderSwitch >= 512){
			HEX_clear_ASM(HEX0|HEX1|HEX2|HEX3);	
			}
		else{
			/*Go HEX display by display in if statement*/
			if (read_PB_data_ASM() == 0x00000001){
				HEX_write_ASM(HEX0,sliderSwitch);
			}
			else if (read_PB_data_ASM() == 0x00000002){
				HEX_write_ASM(HEX1,sliderSwitch);
			}
			else if (read_PB_data_ASM() == 0x00000004){
				HEX_write_ASM(HEX2,sliderSwitch);
			}
			else if (read_PB_data_ASM() == 0x00000008){
				HEX_write_ASM(HEX3,sliderSwitch);
			}
		}
	}
	return 0;
}

//Sample program for timer (0-15 count)
//int main() {

//int count0 = 0, count1 = 0, count2 = 0, count3 = 0;
//	HPS_TIM_config_t hps_tim;
//	hps_tim.tim = TIM0|TIM1|TIM2|TIM3;
//	hps_tim.timeout = 1000000;
//	hps_tim.LD_en = 1;
//	hps_tim.INT_en = 1;
//	hps_tim.enable = 1;
//	HPS_TIM_config_ASM(&hps_tim);
//	while (1) {
//		write_LEDs_ASM(read_slider_switches_ASM());
//		if (HPS_TIM_read_INT_ASM(TIM0)) {
//			HPS_TIM_clear_INT_ASM(TIM0);
//			if (++count0 == 16)
//				count0 = 0;
//		HEX_write_ASM(HEX0, (count0+48));
//		}
//		if (HPS_TIM_read_INT_ASM(TIM1)) {
//			HPS_TIM_clear_INT_ASM(TIM1);
//			if (++count1 == 16)
//				count1 = 0;
//			HEX_write_ASM(HEX1, (count1+48));
//		}
//		if (HPS_TIM_read_INT_ASM(TIM2)) {
//			HPS_TIM_clear_INT_ASM(TIM2);
//			if (++count2 == 16)
//				count2 = 0;
//		HEX_write_ASM(HEX2, (count2+48));
//		}
//		if (HPS_TIM_read_INT_ASM(TIM3)) {
//			HPS_TIM_clear_INT_ASM(TIM3);
//			if (++count3 == 16)
//				count3 = 0;
//			HEX_write_ASM(HEX3, (count3+48));
//		}
//	}
//	return 0;
//}

//Section 3: Timer


// Section 4: Timer with interrupt
int main() {
	int_setup(2, (int[]) {73, 199 });
	enable_PB_INT_ASM(PB0 | PB1 | PB2);
	
	int count = 0;
	HPS_TIM_config_t hps_tim;
	//only need one timer
	hps_tim.tim = TIM0;
	hps_tim.timeout = 10000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;

	HPS_TIM_config_ASM(&hps_tim);
	int timerstart=0;
	int micros = 0;
	int seconds = 0;
	int minutes = 0;
	
	while (1) {
		//each 10 ms, we increment, we only go when the subroutine flag is active
		if (hps_tim0_int_flag && timerstart) {
			hps_tim0_int_flag = 0;
			micros += 10; 

			//increment ms until we reach 1000, then +1 second then reset
			if (micros >= 1000) {
				micros -= 1000;
				seconds++;
				//increment seconds, until we reach 60, then +1 minute then reset
				if (seconds >= 60) {
					seconds -= 60;
					minutes++;
					//reset minutes since we have no hours
					if (minutes >= 60) {
						minutes = 0;
					}
				}
			}

			//write on the proper hex display
			HEX_write_ASM(HEX0, ((micros % 100) / 10) + 48);
			HEX_write_ASM(HEX1, (micros / 100) + 48);
			HEX_write_ASM(HEX2, (seconds % 10) + 48);
			HEX_write_ASM(HEX3, (seconds / 10) + 48);
			HEX_write_ASM(HEX4, (minutes % 10) + 48);
			HEX_write_ASM(HEX5, (minutes / 10) + 48);
		}
		//if pushbutton flag active, the ISR is active, we do something according to which button pressed
		if (pb_int_flag != 0){
			if(pb_int_flag == 1)
				timerstart=1;
			else if(pb_int_flag == 2)
				timerstart = 0;
			else if(pb_int_flag == 4 & timerstart==0){
				micros = 0;
				seconds = 0;
				minutes = 0;
				HEX_write_ASM(HEX0, 48);
				HEX_write_ASM(HEX1, 48);
				HEX_write_ASM(HEX2, 48);
				HEX_write_ASM(HEX3, 48);
				HEX_write_ASM(HEX4, 48);
				HEX_write_ASM(HEX5, 48);
			}
			pb_int_flag = 0;
		}
	}
	
	return 0;
}
