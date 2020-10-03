require_relative 'classes.rb'

STDOUT.puts "10 самых дорогих ВМ \n"
Pc.most_expensive(10)

STDOUT.puts "10 самых дешевых ВМ \n"
Pc.cheapest(10)

STDOUT.puts "10 самых объемных по параметру type ВМ. Type = sata \n"
Pc.largest_by_type(10, 'sata')

STDOUT.puts "10 ВМ у которых подключено больше всего дополнительных дисков по количеству \n"
Pc.most_additional_disks_attached_quantity(10)

STDOUT.puts "10 ВМ у которых подключено больше всего дополнительных дисков по объему \n"
Pc.most_additional_disks_attached_volume(10)
