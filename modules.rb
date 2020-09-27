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
    check_quantity(quantity)

    find_and_report(quantity, 'max_by')

  end

  def self.cheapest(quantity = 1)
    check_quantity(quantity)

    find_and_report(quantity, 'min_by')

  end

  def self.largest_by_type_parameter(type)
    
  end

  def self.most_additional_disks_attached_quantity
  end

  def self.most_additional_disks_attached_volume
  end

  private

  def self.check_quantity(quantity)
    if quantity.negative? || quantity.zero?
      return STDOUT.puts 'Are you bored, master?'
    end
  end

  def self.find_and_report(quantity, choice)
    if quantity == 1

      pc_id = array_of_cost.each_with_index
              .send(choice.to_sym) { | cost, id | cost }

      report(pc_id)

    else

      pc_ids = array_of_cost.each_with_index
               .send(choice.to_sym,quantity) { | cost ,id | cost }

      pc_ids.each do |pc_id|
        report(pc_id)
      end

    end
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

  def self.report(pc_id)
    STDOUT.puts "    Cost of PC is #{pc_id.first} rubls

      PC id           = #{@csv_vms[pc_id.last][0]}
      PC CPU          = #{@csv_vms[pc_id.last][1]}
      PC RUM          = #{@csv_vms[pc_id.last][2]}
      PC HDD type     = #{@csv_vms[pc_id.last][3]}
      PC HDD capacity = #{@csv_vms[pc_id.last][4]}
      
        PC additional hard drives:
      "
      
      arr = @csv_volumes.select { |drivers| drivers[0] == pc_id[1] }.each do |d|
        STDOUT.puts "      HDD type     = #{d[1]}"
        STDOUT.puts "      HDD capacity = #{d[2]}"
        STDOUT.puts "      -----------------------"
      end
  end

end