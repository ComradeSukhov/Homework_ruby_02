require_relative 'classes.rb'

STDOUT.puts "10 самых дорогих ВМ \n \n \n"
Pc.most_expensive(10)

STDOUT.puts "10 самых дешевых ВМ \n \n \n"
Pc.cheapest(10)

STDOUT.puts "10 самых объемных по параметру type ВМ. Type = sata \n \n \n"
Pc.largest_by_type(10, 'sata')

STDOUT.puts "10 ВМ у которых подключено больше всего дополнительных дисков по количеству \n \n \n"
Pc.most_additional_disks_attached_quantity(10)

STDOUT.puts "10 ВМ у которых подключено больше всего дополнительных дисков по объему \n \n \n"
Pc.most_additional_disks_attached_volume(10)
