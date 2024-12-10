#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/9

require "bundler/setup"
Bundler.require

TYPES = %i[file empty]

# [:file, N, ID] - file blocks
# [:empty, N]    - empty blocks

blocks = File.read("#{__dir__}/day-09.txt")
  .chomp
  .chars
  .map
  .with_index do |ch, idx|
    [TYPES[idx % 2], ch.to_i, idx / 2]
  end

def reorder_blocks(blocks)
  blocks = blocks.dup

  empty_idx = 1
  file_idx = blocks.rindex { |block| block[0] == :file }

  while empty_idx < file_idx
    _, empty_size = blocks[empty_idx]
    _, file_size, file_id = blocks[file_idx]

    can_move = [empty_size, file_size].min
    remaining_empty_size = empty_size - can_move
    remaining_file_size = file_size - can_move

    if remaining_empty_size > 0
      blocks[empty_idx] = [:empty, remaining_empty_size]
      blocks.insert(empty_idx, [:file, can_move, file_id])
      empty_idx += 1
      file_idx += 1
    else
      blocks[empty_idx] = [:file, can_move, file_id]
      loop do
        empty_idx += 1
        break if empty_idx > file_idx || blocks[empty_idx][0] == :empty
      end
    end

    if remaining_file_size > 0
      blocks[file_idx] = [:file, remaining_file_size, file_id]
      blocks.insert(file_idx + 1, [:empty, can_move])
    else
      blocks[file_idx] = [:empty, can_move]
      file_idx = blocks[...file_idx].rindex { |block| block[0] == :file }
      break if file_idx.nil? || file_idx < empty_idx
    end
  end

  blocks
end

def checksum_blocks(blocks)
  result = 0
  position = 0

  blocks.each do |block|
    type, size, id = block

    if type == :empty
      position += size
      next
    end

    size.times do
      result += position * id
      position += 1
    end
  end

  result
end

reordered = reorder_blocks(blocks)
checksum = checksum_blocks(reordered)

puts checksum

def reorder_whole_blocks(blocks)
  blocks = blocks.dup

  file_idx = blocks.rindex { |block| block[0] == :file }

  while file_idx
    empty_idx = blocks[...file_idx].find_index do |block|
      block[0] == :empty && block[1] >= blocks[file_idx][1]
    end

    unless empty_idx
      file_idx = blocks[...file_idx].rindex { |block| block[0] == :file }
      next
    end

    _, empty_size = blocks[empty_idx]
    _, file_size, file_id = blocks[file_idx]

    remaining_empty_size = empty_size - file_size

    blocks[empty_idx] = [:file, file_size, file_id]
    blocks[file_idx] = [:empty, file_size]

    if remaining_empty_size > 0
      empty_idx += 1
      file_idx += 1
      blocks.insert(empty_idx, [:empty, remaining_empty_size])
    end

    file_idx = blocks[...file_idx].rindex { |block| block[0] == :file }
  end

  blocks
end

reordered = reorder_whole_blocks(blocks)
checksum = checksum_blocks(reordered)

puts checksum
