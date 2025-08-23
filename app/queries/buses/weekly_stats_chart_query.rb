module Buses
  class WeeklyStatsChartQuery
    def self.call(user)
      week_start = Date.today.beginning_of_week
      week_end = Date.today.end_of_week

      records = user.buses.approved
        .left_outer_joins(:reservations)
        .where("reservations.date BETWEEN ? AND ? OR reservations.id IS NULL OR reservations.bus_id IS NULL", week_start, week_end)
        .group("buses.id, buses.name")
        .select(<<~SQL)
          buses.name AS name,
          SUM(CASE WHEN reservations.date = '#{week_start}' THEN 1 ELSE 0 END) AS monday,
          SUM(CASE WHEN reservations.date = '#{week_start + 1.day}' THEN 1 ELSE 0 END) AS tuesday,
          SUM(CASE WHEN reservations.date = '#{week_start + 2.days}' THEN 1 ELSE 0 END) AS wednesday,
          SUM(CASE WHEN reservations.date = '#{week_start + 3.days}' THEN 1 ELSE 0 END) AS thursday,
          SUM(CASE WHEN reservations.date = '#{week_start + 4.days}' THEN 1 ELSE 0 END) AS friday,
          SUM(CASE WHEN reservations.date = '#{week_start + 5.days}' THEN 1 ELSE 0 END) AS saturday,
          SUM(CASE WHEN reservations.date = '#{week_start + 6.days}' THEN 1 ELSE 0 END) AS sunday
        SQL

      records.map do |r|
        {
          name: r.name,
          data: {
            "Monday" => r["monday"].to_i,
            "Tuesday" => r["tuesday"].to_i,
            "Wednesday" => r["wednesday"].to_i,
            "Thursday" => r["thursday"].to_i,
            "Friday" => r["friday"].to_i,
            "Saturday" => r["saturday"].to_i,
            "Sunday" => r["sunday"].to_i,
          },
        }
      end
    end
  end
end

module Buses
  class WeeklyStatsChartQuery
    def self.call(user)
      week_start = Date.today.beginning_of_week
      week_end = Date.today.end_of_week

      records = user.buses.approved
        .left_outer_joins(:reservations)
        .where("reservations.date BETWEEN ? AND ? OR reservations.id IS NULL OR reservations.bus_id IS NULL", week_start, week_end)
        .group("buses.id, buses.name")
        .select("buses.name AS name, #{day_case_sql(week_start)}")

      records.map do |r|
        {
          name: r.name,
          data: {
            "Monday" => r["monday"].to_i,
            "Tuesday" => r["tuesday"].to_i,
            "Wednesday" => r["wednesday"].to_i,
            "Thursday" => r["thursday"].to_i,
            "Friday" => r["friday"].to_i,
            "Saturday" => r["saturday"].to_i,
            "Sunday" => r["sunday"].to_i,
          },
        }
      end
    end

    def self.day_case_sql(start_date)
      (0..6).map do |offset|
        day = start_date + offset.days
        <<~SQL.squish
          SUM(CASE WHEN reservations.date = '#{day}' THEN 1 ELSE 0 END) AS #{day.strftime("%A").downcase}
        SQL
      end.join(", ")
    end
  end
end
