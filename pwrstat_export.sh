from prometheus_client import start_http_server, Summary, Info, Gauge
import random
import time
import subprocess
iModel_Name = Info('ups_model_name', 'UPS Model Name')
iFirmware_Number = Info('ups_firmware_number', 'UPS Firmware Number')
gRating_Voltage = Gauge('ups_rating_voltage', 'Rating Voltage')
gRating_Power = Gauge('ups_rating_power', 'Rating Max Watt Draw')
iState = Info('ups_state', 'State of UPS')
iPower_Supply_by = Info('ups_power_supply_by', 'Source of Power')
gUtility_Voltage = Gauge('ups_utility_voltage', 'Voltage from the wall')
gOutput_Voltage = Gauge('ups_output_voltage', 'Output Voltage')
gBattery_Capacity = Gauge('ups_battery_capacity', 'Current Battery Capacity 0-100')
gRemaining_Runtime = Gauge('ups_remaining_runtime', 'Estimated runtime in event of power loss')
gLoad = Gauge('ups_Load', 'UPS Side Load in Watts')
iLine_Interaction = Info('ups_line_interaction', 'Line Interaction')
iTest_Result = Info('ups_test_result', 'Last Test Result')
iLast_Power_Event = Info('ups_last_power_event', 'Last Power Event')



def get_data():
    ps = subprocess.Popen(('pwrstat', '-status'), stdout=subprocess.PIPE)
    sed = subprocess.Popen(('sed', '-E', 's/^\\t*//g;s/\\.+ /=/g;s/ /_/g;/:$/d;/^$/d;s/([^t]=[^_]+).*/\\1/g'), stdin=ps.stdout, stdout=subprocess.PIPE)
    stdout,stderr = sed.communicate()
    print stdout
    result={}
    for line in stdout.splitlines():
        parts=line.split("=")
        key=parts[0]
        value=parts[1]
        result[key]=value
    if result['State'] == "Lost":
	return
    if "Model_Name" in result: iModel_Name.info({'model_name': result['Model_Name']})
    if "Firmware_Number" in result: iFirmware_Number.info({'firmware_number': result['Firmware_Number']})
    if "Rating_Voltage" in result: gRating_Voltage.set(result['Rating_Voltage'])
    if "Rating_Power" in result: gRating_Power.set(result['Rating_Power'])
    if "State" in result: iState.info({'state': result['State']})
    if "Power_Supply_by" in result: iPower_Supply_by.info({'power_supply_by': result['Power_Supply_by']})
    if "Utility_Voltage" in result: gUtility_Voltage.set(result['Utility_Voltage'])
    if "Output_Voltage" in result: gOutput_Voltage.set(result['Output_Voltage'])
    if "Battery_Capacity" in result: gBattery_Capacity.set(result['Battery_Capacity'])
    if "Remaining_Runtime" in result: gRemaining_Runtime.set(result['Remaining_Runtime'])
    if "Load" in result: gLoad.set(result['Load'])
    if "Line_Interaction" in result: iLine_Interaction.info({'line_interaction': result['Line_Interaction']})
    if "Test_Result" in result: iTest_Result.info({'test_result': result['Test_Result'].replace("_"," ")})
    if "Last_Power_Event" in result: iLast_Power_Event.info({'last_power_event': result['Last_Power_Event']})
    
if __name__ == '__main__':
    start_http_server(8777)
    while True:
        time.sleep(1)
        get_data()
