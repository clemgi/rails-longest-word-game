require 'open-uri'

class LongwordController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    query = params[:query]
    grid = params[:grid].split("")
    start_time = Time.at(params[:start_time].to_i)
    end_time = Time.now
    @result = run_game(query, grid, start_time, end_time)
  end

    # @included = included?(@query, @grid)
    # @translation = get_translation(@query)

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end


  def included?(query, grid)
    the_grid = grid.clone
    query.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    grid.size == query.size + the_grid.size
  end


  def get_translation(query)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{query.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

  def score_and_message(query, translation, grid, time)
  if translation
    if included?(query.upcase, grid)
      score = compute_score(query, time)
      [score, "well done"]
    else
      [0, "not in the grid"]
    end
  else
    [0, "not an english word"]
  end
end

def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)

  result = { time: end_time - start_time }

  result[:translation] = get_translation(attempt)
  result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid, result[:time])
  result[:query] = attempt
  result[:grid] = grid
  result
end

end
