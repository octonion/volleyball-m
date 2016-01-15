#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

nthreads = 1

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = ARGV[1].to_i

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

roster_xpath = '//*[@id="stat_grid"]/tbody/tr'

ncaa_teams = CSV.open("tsv/ncaa_teams_#{year}_#{division}.tsv",
                      "r",
                      {:col_sep => "\t", :headers => TRUE})
ncaa_team_rosters = CSV.open("tsv/ncaa_team_rosters_mt_#{year}_#{division}.tsv",
                             "w",
                             {:col_sep => "\t"})

#http://stats.ncaa.org/team/roster/11540?org_id=2

# Header for team file

ncaa_team_rosters << ["year","year_id","team_id","team_name","jersey_number","player_id","player_name","player_url","position","height","class_year","games_played","games_started"]

# Get team IDs

teams = []
ncaa_teams.each do |team|
  teams << team
end

n = teams.size

tpt = (n.to_f/nthreads.to_f).ceil

threads = []

# One agent for each thread?

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'
agent.robots = false

teams.each_slice(tpt).with_index do |teams_slice,i|

  threads << Thread.new(teams_slice) do |t_teams|

    t_teams.each_with_index do |team,j|

      sleep_time = base_sleep

      year = team[0]
      year_id = team[1]
      team_id = team[3]
      team_name = team[4]

      team_roster_url = "http://stats.ncaa.org/team/roster/#{year_id}?org_id=#{team_id}"

      #print "Sleep #{sleep_time} ... "
      sleep sleep_time

      found_players = 0
      missing_id = 0

      tries = 0
      begin
        doc = Nokogiri::HTML(agent.get(team_roster_url).body)
      rescue
        sleep_time += sleep_increment
        #print "sleep #{sleep_time} ... "
        sleep sleep_time
        tries += 1
        if (tries > retries)
          next
        else
          retry
        end
      end

      sleep_time = base_sleep

      print "#{i} #{year} #{team_name} ..."

      doc.xpath(roster_xpath).each do |player|

        row = [year, year_id, team_id, team_name]
        player.xpath("td").each_with_index do |element,k|
          case k
          when 1
            player_name = element.text.strip

            link = element.search("a").first
            if (link==nil)
              missing_id += 1
              link_url = nil
              player_id = nil
              player_url = nil
            else
              link_url = link.attributes["href"].text
              parameters = link_url.split("/")[-1]

              # player_id

              player_id = parameters.split("=")[2]

              # opponent URL

              player_url = base_url+link_url
            end

            found_players += 1
            row += [player_id, player_name, player_url]
          else
            field_string = element.text.strip

            row += [field_string]
          end
        end

        ncaa_team_rosters << row
    
      end

      print " #{found_players} players, #{missing_id} missing ID\n"

    end

  end

end

threads.each(&:join)

ncaa_team_rosters.close
