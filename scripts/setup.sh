#!/bin/bash

set -e

echo "sozo build && sozo migrate"
output=$(sozo build && sozo migrate)

contract_addresses=$(echo "$output" | awk '/Contract address/ {print $NF}')
world_address=$(echo "$output" | awk '/Successfully migrated World at address/ {print $NF}')

action_system=$(echo "$contract_addresses" | awk 'NR==3')
character_system=$(echo "$contract_addresses" | awk 'NR==4')
map_cc_system=$(echo "$contract_addresses" | awk 'NR==5')
match_system=$(echo "$contract_addresses" | awk 'NR==6')
move_system=$(echo "$contract_addresses" | awk 'NR==7')
ranking_system=$(echo "$contract_addresses" | awk 'NR==8')
recommendation_system=$(echo "$contract_addresses" | awk 'NR==9')
skill_system=$(echo "$contract_addresses" | awk 'NR==10')
stadistics_system=$(echo "$contract_addresses" | awk 'NR==11')
turn_system=$(echo "$contract_addresses" | awk 'NR==12')

echo -e "\nSystems: "
echo "action_system: $action_system"
echo "character_system: $character_system"
echo "map_cc_system: $map_cc_system"
echo "match_system: $match_system"
echo "move_system: $move_system" 
echo "ranking_system: $ranking_system"
echo "recommendation_system: $recommendation_system"
echo "skill_system: $skill_system"
echo "stadistics_system: $stadistics_system"
echo "turn_system: $turn_system"
echo -e "\n🎉 World Address: $world_address"

echo -e "\n Setup ..."

# Init

## Character system
sozo execute ${character_system} init
sleep 3

## Skill system
sozo execute ${skill_system} init
sleep 3

## MapCC system
sozo execute ${map_cc_system} init
sleep 3

## Mint adversary:
### Goblin1
sozo execute ${character_system} mint -c 4,0xacf1a6dc520d08ea7521b23f76ce84c6,1
sleep 3

### Goblin2
sozo execute ${character_system} mint -c 6,0xacf1a6dc520d08ea7521b23f76ce84c6,1
sleep 3

echo -e "\n✅ Setup finish!"

echo -e "\n✅ Init Torii!"
torii --world ${world_address}