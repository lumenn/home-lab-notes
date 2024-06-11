#ipmi #supermicro #mobo

Reducing speed of fans - it's enough to update Lower Critical Range with this command (get correct values from fan specs) this is based on that [post](https://www.truenas.com/community/resources/how-to-change-ipmi-sensor-thresholds-using-ipmitool.35/):
```
ipmitool sensor thresh FAN{ID} lower 100 200 200
```
