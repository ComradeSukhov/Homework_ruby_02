module Pc
  require 'csv'

  def self.reveal_integers(arr)
    arr.map { |val| val.match?(/\A\d+\z/) ? val.to_i : val }
  end

  @csv_vms     = CSV.open('02_ruby_vms.csv').map { |item| reveal_integers(item) }
  @csv_prices  = CSV.open('02_ruby_prices.csv').map { |item| reveal_integers(item) }
  @csv_volumes = CSV.open('02_ruby_volumes.csv').map { |item| reveal_integers(item) }

  def self.most_expensive(quantity = 1)
    check_quantity(quantity)
    find_and_report(quantity, :max_by, array_of_costs)
  end

  def self.cheapest(quantity = 1)
    check_quantity(quantity)
    find_and_report(quantity, :min_by, array_of_costs)
  end

  def self.largest_by_type(type, quantity = 1)
    check_quantity(quantity)
    find_and_report(quantity, :max_by, array_of_volumes(type))
  end

  # def self.most_additional_disks_attached_quantity
  # end

  # def self.most_additional_disks_attached_volume
  # end

  private

  def self.check_quantity(quantity)
    return STDOUT.puts 'Are you bored, master?' unless quantity.positive?
  end

  def self.find_and_report(quantity, choice, array)
    if quantity == 1
      pc_id = array.each_with_index
                   .send(choice) { |cost, id| cost }

      report(pc_id)

    else
      pc_ids = array.each_with_index
                    .send(choice, quantity) { |cost, id| cost }

      pc_ids.each do |pc_id|
        report(pc_id)
      end
    end
  end

  def self.array_of_costs
    cpu_price = @csv_prices[0][1]
    ram_price = @csv_prices[1][1]
    pc_costs  = @csv_vms.map do |pc|
                  pc_id           = pc[0]
                  pc_cpu          = pc[1]
                  pc_rum          = pc[2]
                  pc_hdd_type     = pc[3]
                  pc_hdd_capacity = pc[4]

                  cost = pc_cpu          * cpu_price +
                         pc_rum          * ram_price +
                         pc_hdd_capacity * hdd_price(pc_hdd_type) +
                         additional_hdd_cost(pc_id)
                end
    pc_costs.map{ |cost| cost / 100 }
  end

  def self.additional_hdd_cost(pc_id)
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
    STDOUT.puts "Cost of PC is #{pc_id.first} rubles\n" \
                "\n" \
                "PC id           = #{@csv_vms[pc_id.last][0]}\n" \
                "PC CPU          = #{@csv_vms[pc_id.last][1]}\n" \
                "PC RUM          = #{@csv_vms[pc_id.last][2]}\n" \
                "PC HDD type     = #{@csv_vms[pc_id.last][3]}\n" \
                "PC HDD capacity = #{@csv_vms[pc_id.last][4]}\n" \
                "\n" \
                "PC additional hard drives:\n"

    @csv_volumes.select { |drivers| drivers[0] == pc_id[1] }.each do |d|
      STDOUT.puts "HDD type     = #{d[1]}\n" \
                  "HDD capacity = #{d[2]}\n" \
                  "-----------------------\n"
    end
  end

  def self.array_of_volumes(type)
    arr_volumes = @csv_vms.map do |pc|
      pc_driver      = pc[3] == type ? pc[4] : 0
      pc_add_drivers = @csv_volumes.select do |driver|
                         driver[0] == pc[0] && driver[3] == type
                       end.inject(0) { |volume_sum, driver| driver[2] }

      pc_driver + pc_add_drivers
    end
  end
end
