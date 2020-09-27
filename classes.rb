class Pc
  require 'csv'

  # Меняет на числа те строки, который выражают собой числа
  def self.reveal_integers(arr)
    arr.map { |val| val.match?(/\A\d+\z/) ? val.to_i : val }
  end
  
  @csv_vms     = CSV.open('02_ruby_vms.csv').map { |item| reveal_integers(item) }
  @csv_prices  = CSV.open('02_ruby_prices.csv').map { |item| reveal_integers(item) }
  @csv_volumes = CSV.open('02_ruby_volumes.csv').map { |item| reveal_integers(item) }

  # Выводит n самых дорогих ВМ
  def self.most_expensive(quantity = 1)
    check_quantity(quantity)

    # Общий метод который находит максимальные значения из массива стоимостей
    # ВМ и выводит отчет пользователю в терминал
    find_and_report(quantity, :max_by, array_of_costs)
  end

  # Выводит n самых дешевых ВМ
  def self.cheapest(quantity = 1)
    check_quantity(quantity)

    # Общий метод который находит минимальные значения из массива стоимостей
    # ВМ и выводит отчет пользователю в терминал
    find_and_report(quantity, :min_by, array_of_costs)
  end

  # Выводит n самых объемных ВМ по параметру type
  def self.largest_by_type(quantity = 1, type)
    check_quantity(quantity)

    # Общий метод который находит максимальные значения из массива объемов
    # дисков ВМ с требуемым типом и выводит отчет пользователю в терминал
    find_and_report(quantity, :max_by, array_of_volumes(type))
  end

  # Выводит n ВМ у которых подключено больше всего дополнительных дисков по
  # количеству и с учетом типа диска если параметр hdd_type указан
  def self.most_additional_disks_attached_quantity(pc_quantity = 1, hdd_type = nil)
    check_quantity(pc_quantity)

    # Общий метод который находит максимальные значения из массива колличества
    # дополнительных дисков ВМ с требуемым типом или все подряд если тип не 
    # указан и выводит отчет пользователю в терминал
    find_and_report(pc_quantity, :max_by, array_of_quant_add_disks(hdd_type))
  end

  # Выводит n ВМ у которых подключено больше всего дополнительных дисков
  # по объему и с учетом типа диска если параметр hdd_type указан
  def self.most_additional_disks_attached_volume(pc_quantity = 1, hdd_type = nil)
    check_quantity(pc_quantity)

    # Общий метод который находит максимальные значения из массива объемов
    # дополнительных дисков ВМ с требуемым типом и выводит отчет пользователю
    # в терминал
    find_and_report(pc_quantity, :max_by, array_of_vol_add_disks(hdd_type))
  end

  private

  # Проверка на ввод 0 или отрицательных значений
  # В случае некорректного ввода прерывает работу программы выводом сообщения  
  # в терминал
  def self.check_quantity(quantity)
    return STDOUT.puts 'Are you bored, master?' unless quantity.positive?
  end

  # Метод, используемый другими методами для поиска нужных ВМ и выполнения отчета
  # Аргументы:
  #  quantity - количество элементов для запроса
  #  choice   - название метода нужного для запроса: max_by или min_by
  #  array    - массив в котором нужно произвести выбор значений
  def self.find_and_report(quantity, choice, array)
    
    # В зависимости от количества нам нужно будет по разному вызывать метод send
    if quantity == 1

      # Индексируем массив что бы при поиске нужного значения вместе с ним
      # получить и его индекс. Переменная содержит enumerator.
      indexed_array = array.each_with_index

      # Получаем массив с максимальным или минимальным значением и id значения,
      # которое соответствует id ВМ 
      value_and_id = indexed_array.send(choice) { |value, id| value }

      # Берем id. Он потребуется для вызова метода отчетов
      pc_id = value_and_id.last

      report(pc_id)

    # В случае когда quantity больше единицы нам всегда нужно будет запускать
    # метод max_by или min_by для находения нескольких значений. 
    else
      indexed_array      = array.each_with_index
      
      # Получаем двумерный массив нажных нам значений в паре с id значения,
      # которое соответствует id ВМ
      value_and_id_array = indexed_array.send(choice, quantity) {|value,id|value}

      # Получаем массив состоящий из id ВМ которые нужны для отчета
      pc_ids = value_and_id_array.map { | value_and_id | value_and_id.last }

      # Вызываем для каждого id ВМ отчет
      pc_ids.each do |pc_id|
        report(pc_id)
      end
    end
  end

  # Возвращает массив стоимостей ВМ, в котором индекс значения
  # будет соответствовать индексу ВМ в массиве @csv_vms
  def self.array_of_costs
    pc_costs  = @csv_vms.map do |pc|
                  pc_id = pc.first  
                  find_cost(pc_id)
                end
  end

  # Возвращает стоимость дополнительных дисков ВМ
  def self.additional_hdd_cost(pc_id)

    # Получаем массив дополнительных дисков ВМ
    pc_driver_arr = @csv_volumes.select do |drivers|
                      driver_pc_id = drivers[0]
                      driver_pc_id == pc_id
                    end

    # Получаем массив со стоимостями дисков ВМ
    drivers_costs_array = pc_driver_arr.map do |driver|
                          hdd_type     = driver[1]
                          hdd_capacity = driver[2]
                          hdd_price    = hdd_price(hdd_type)

                          hdd_capacity * hdd_price
                        end

    drivers_costs_array.sum
  end

  # Возвращает цену на диск в зависимости от типа
  def self.hdd_price(pc_hdd_type)
    @csv_prices.detect{ |price| price[0] == pc_hdd_type }[1]
  end

  # Выполняет отчет. Принимает id ВМ.
  def self.report(pc_id)
    STDOUT.puts "Cost of PC is #{find_cost(pc_id)} rubles\n" \
                "\n" \
                "PC id           = #{@csv_vms[pc_id][0]}\n" \
                "PC CPU          = #{@csv_vms[pc_id][1]}\n" \
                "PC RUM          = #{@csv_vms[pc_id][2]}\n" \
                "PC HDD type     = #{@csv_vms[pc_id][3]}\n" \
                "PC HDD capacity = #{@csv_vms[pc_id][4]}\n" \
                "\n" \
                "PC additional hard drives:\n"

    @csv_volumes.select { |drivers| drivers[0] == pc_id }.each do |d|
      STDOUT.puts "HDD type     = #{d[1]}\n" \
                  "HDD capacity = #{d[2]}\n" \
                  "-----------------------\n"
    end
    STDOUT.puts "\n\n\n\n\n\n"
  end

  # Возвращает массив сумм объемов дисков ВМ, в котором индекс значения
  # будет соответствовать индексу ВМ в массиве @csv_vms
  def self.array_of_volumes(type)

    # Используем .map что бы создать массив в котором id значений будут 
    # соответствовать id ВМ в массиве @csv_vms
    arr_volumes = @csv_vms.map do |pc|

      # Если основой диск не подходящего типа, то в переменную кладем 0
      pc_driver_vol = pc[3] == type ? pc[4] : 0

      # Из массива всех доп. дисков выбираем те, которые относятся к нужной ВМ
      # и подходящего типа
      pc_add_drivers = @csv_volumes.select do |driver|
                         driver[0] == pc[0] && driver[1] == type
                       end

      # Суммируем значения объемов дисков
      pc_add_driv_vol = pc_add_drivers.inject(0) do |volume_sum, driver|
                          driver_vol = driver[2]
                          volume_sum + driver_vol
                        end

      pc_driver_vol + pc_add_driv_vol
    end
  end

  # Возвращает массив количеств дополнительных дисков, в котором индекс значения
  # будет соответствовать индексу ВМ в массиве @csv_vms
  def self.array_of_quant_add_disks(hdd_type)
    
    # Используем .map что бы создать массив в котором id значений будут 
    # соответствовать id ВМ в массиве @csv_vms
    array_of_quant = @csv_vms.map do |pc|
      pc_id     = pc[0]

      # Выбираем нужные диски и кладем в массив
      add_disks = @csv_volumes.select do |disk|
                    pc_disk_id    = disk[0]
                    disk_hdd_type = disk[1]
                    if hdd_type == nil
                      pc_disk_id == pc_id
                    else
                      pc_disk_id == pc_id && disk_hdd_type == hdd_type 
                    end
                  end

      # Так как каждый элемент это диск, то размер массива вернет нам количество
      # дисков
      add_disks.size
    end
  end

  # Возвращает массив объемов дополнительных дисков, в котором индекс значения
  # будет соответствовать индексу ВМ в массиве @csv_vms
  def self.array_of_vol_add_disks(hdd_type)
    array_of_vol = @csv_vms.map do |pc|
      pc_id = pc[0]

      # Выбираем нужные диски и кладем в массив
      add_disks_vol = @csv_volumes.select do |disk|
                        pc_disk_id    = disk[0]
                        disk_hdd_type = disk[1]

                        # Если hdd_type nil значит мы не учитываем тип и 
                        # выбираем все диски нужной ВМ
                        if hdd_type == nil
                          pc_disk_id == pc_id
                        else
                          pc_disk_id == pc_id && disk_hdd_type == hdd_type 
                        end
                      end
      
      # Суммируем объемы всех дисков
      add_disks_vol.inject(0) do |sum, disk|
                      disk_vol = disk[2]
                      sum + disk_vol
                    end
    end
  end

  # Возвращает стоимость ВМ
  def self.find_cost(id)
    cpu_price = @csv_prices[0][1]
    ram_price = @csv_prices[1][1]

    pc_id           = id
    pc_cpu          = @csv_vms[id][1]
    pc_rum          = @csv_vms[id][2]
    pc_hdd_type     = @csv_vms[id][3]
    pc_hdd_capacity = @csv_vms[id][4]

    cost = pc_cpu          * cpu_price +
           pc_rum          * ram_price +
           pc_hdd_capacity * hdd_price(pc_hdd_type) +
           additional_hdd_cost(pc_id)

    # Цены изначально указаны в копейках. Переводим стоимость в рубли
    cost / 100 
  end
end
