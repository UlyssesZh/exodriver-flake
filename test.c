#include <stdio.h>
#include "labjackusb.h"

int main() {
	printf("LJ_VENDOR_ID: 0x%04x\n", LJ_VENDOR_ID);
	printf("labjackusb version: %f\n", LJUSB_GetLibraryVersion());
	return 0;
}
