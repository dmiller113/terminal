#### Barrier Abilities

##### Containment:  
**Range Formula**: *In Sight*  
**Min Damage**: 2(Pow%)(Scan \* .025 + 1)  
**Max Damage**: 3(Pow%)(Pow \* .025 + 1)  
**Scaling Stat**: Hardening  
**Scaling Amount**: .33  
**Damage Type**: Normal  
**Cooldown Formula**: 6 - (1.5 \* util%)~  
**Added Effects**: Effected Targets gain the Containment debuff, stacking up to 3 times. If used against a target that has 3 stacks of Containment, it instead consumes those stacks and creates a Quarantine tile under the target.  
**Containment**: Deals (7 \* util%) less damage per stack of Containment. Lasts (3 + 2 \* util%)~ turns.  

##### Sanitize:
**Range Formula**: *In Sight*  
**Min Damage**: 1(Pow%)(Scan \* .025 + 1)  
**Max Damage**: 2(Pow%)(Pow \* .025 + 1)  
**Scaling Stat**: Containment Stacks  
**Scaling Amount**: 100% per Stack  
**Damage Type**: Normal  
**Cooldown Formula**: 12 - (2 \* util%)  
**Added Effects**: Consumes Containment stacks.  

##### System Aggro:
**Range Formula**: PBAoE (.33 \* Scan)  
**Min Damage**: 0.5(Pow%)(Scan \* .025 + 1)  
**Max Damage**: 1(Pow%)(Pow \* .025 + 1)  
**Scaling Stat**: Scan  
**Scaling Amount**: .15  
**Damage Type**: Normal  
**Cooldown Formula**: 18 - (1 \* util%)  
**Added Effects**: Moves the user 1 tile to a free space then fires the PBAoE effecting all entities. All friendly entities take no damage and gain the Reinforcement buff. All hostile entities gain the Taunt debuff.
**Reinforcement**: Deal (12% \* Util%) more damage. Lasts (5 + 0.5 \* Power) turns.  
**Taunt**: Must deal ((5 \* Hardening) \* Pow%) damage to originating entity before ((10 - 0.5 \* Power) min 6) turns or suffer focused damage equal to 1/4 its current HP and become Lagged.
**Lagged**: Skips its next turn.
