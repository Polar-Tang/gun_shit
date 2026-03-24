[] Migrate all the remotes events to blink
#### Be aware of what's hit
[.] Tag the part which is hit and send it to the backend
[.] Figure out how to validate, we can do something like use the raycastPosition from the backend and check its position is not too far of the tagged part position
[] Using tag for the important parts, if the object can be destroyed HasTa("destroyable") if its head HasTa("player_hear") then do more damage end

### Ensure system is right
[] put some dummies which moves and test wheter the damage, raycats, etc are accurate

### Start movement system
###### Slide
[] We can reuse some dashing code
