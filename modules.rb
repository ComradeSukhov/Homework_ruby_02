module Pc

  @csv_vms     = CSV.open('02_ruby_vms.csv').map do |e|
    [ e[0].to_i, e[1].to_i, e[2].to_i, e[3], e[4].to_i ]
  end
  @csv_prices  = CSV.open('02_ruby_prices.csv').map do |e|
    [ e[0], e[1].to_i ]
  end
  @csv_volumes = CSV.open('02_ruby_volumes.csv').map do |e|
    [ e[0].to_i, e[1], e[2].to_i ]
  end


  def self.most_expensive(quantity = 1)
    STDOUT.puts array_of_cost.max(quantity)
  end

  def self.cheapest(quantity = 1)
    STDOUT.puts array_of_cost.min(quantity)
  end

  def self.largest_by_type_parameter
  end

  def self.most_additional_disks_attached_quantity
  end

  def self.most_additional_disks_attached_volume
  end

  def self.array_of_cost
    cpu_price = @csv_prices[0][1]
    rum_price = @csv_prices[1][1]

    pc_costs = @csv_vms.map do |pc|
      pc_id              = pc[0]
      pc_cpu             = pc[1]
      pc_rum             = pc[2]
      pc_hdd_type        = pc[3]
      pc_hdd_capacity    = pc[4]
            
      cost = pc_cpu * cpu_price +
             pc_rum * rum_price +
             pc_hdd_capacity * hdd_price(pc_hdd_type) +
             cost_add_hard_drives(pc_id)
              

    end

      pc_costs.map{ |cost| cost / 100 }

  end

  def self.cost_add_hard_drives(pc_id)
    pc_driver_list    = @csv_volumes.select{ |drivers| drivers[0] == pc_id }
    arr_costs_drivers = pc_driver_list.map do |driver|

      hdd_type     = driver[1]
      hdd_capacity = driver[2].to_i
      hdd_price    = hdd_price(hdd_type)

      hdd_capacity * hdd_price

      end
      
    arr_costs_drivers.sum

  end

  def self.hdd_price(pc_hdd_type)
    @csv_prices.detect{ |price| price[0] == pc_hdd_type }[1]
  end

end