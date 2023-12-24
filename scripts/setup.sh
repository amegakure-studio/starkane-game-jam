#!/bin/bash

set -e

echo "sozo build && sozo migrate"
output=$(sozo build && sozo migrate)

contract_addresses=$(echo "$output" | awk '/Contract address/ {print $NF}')
world_address=$(echo "$output" | awk '/Successfully migrated World at address/ {print $NF}')

action_system=$(echo "$contract_addresses" | awk 'NR==3')
character_system=$(echo "$contract_addresses" | awk 'NR==4')
map_system=$(echo "$contract_addresses" | awk 'NR==5')
match_system=$(echo "$contract_addresses" | awk 'NR==6')
move_system=$(echo "$contract_addresses" | awk 'NR==7')
ranking_system=$(echo "$contract_addresses" | awk 'NR==8')
skill_system=$(echo "$contract_addresses" | awk 'NR==9')
stadistics_system=$(echo "$contract_addresses" | awk 'NR==10')
turn_system=$(echo "$contract_addresses" | awk 'NR==11')

echo -e "\nSystems: "
echo "action_system: $action_system"
echo "character_system: $character_system"
echo "map_system: $map_system"
echo "match_system: $match_system"
echo "move_system: $move_system" 
echo "ranking_system: $ranking_system"
echo "skill_system: $skill_system"
echo "stadistics_system: $stadistics_system"
echo "turn_system: $turn_system"
echo -e "\n🎉 World Address: $world_address"

echo -e "\n Setup ..."

# [Create]
sozo execute ${character_system} init

sozo execute ${skill_system} init

sozo execute ${map_system} init

# TODO: es para pruebas
sozo execute ${character_system} mint -c 3,1,1

sozo execute ${character_system} mint -c 3,2,1

sozo execute ${match_system} init -c 2,1,3,2,3

echo -e "\n✅ Setup finish!"