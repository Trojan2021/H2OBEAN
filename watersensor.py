import serial
import time


def getAverage():
    serial_port = "COM13"
    baud_rate = 115200
    run_time = 5
    average = 0
    count = 0
    value = 0

    try:
        ser = serial.Serial(serial_port, baud_rate)
        start_time = time.time()

        while time.time() - start_time < run_time:
            line = ser.readline()
            if line != "":
                value += int(line.decode("utf-8").strip())
                count += 1
                print(line.decode("utf-8").strip())

        average = value / count
    except serial.SerialException:
        print(f"Failed to open serial port {serial_port}. Make sure it's correct.")
    except KeyboardInterrupt:
        print("Serial reading stopped.")
    finally:
        if "ser" in locals():
            ser.close()

    return int(round(average))
