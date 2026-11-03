module ManageIQ
  module Loggers
    class File < Base
      def contents(line_count = 1_000, buffer_size = 8_192)
        return [] unless logdev&.filename && ::File.exist?(logdev.filename)

        tail(line_count, buffer_size)
          .select { |line| line&.unpack("U*") rescue nil }
          .map { |line| line.force_encoding("utf-8") }
      end

      private

      def tail(line_count, buffer_size)
        lines = []

        ::File.open(logdev.filename, 'r') do |file|
          # Start from the end of the file
          file.seek(0, IO::SEEK_END)
          file_size = file.pos

          # If file is empty, return empty array
          return [] if file_size.zero?

          partial_line = ""
          position     = file_size

          # Read backwards in chunks until we have enough lines
          while position > 0 && (line_count.nil? || lines.size < line_count)
            # Calculate how much to read
            chunk_size = [buffer_size, position].min
            position -= chunk_size

            # Seek to position and read chunk
            file.seek(position, IO::SEEK_SET)
            chunk = file.read(chunk_size)

            # Split into lines
            chunk_lines = chunk.split("\n")

            # Handle the last line in chunk (partial line continuing to next chunk)
            # by appending the saved partial line to the last line of this chunk
            chunk_lines[-1] = chunk_lines[-1] + partial_line unless partial_line.empty?

            # If we're not at the start of the file, the first line is partial
            partial_line = position > 0 ? chunk_lines.shift : ""

            # Prepend complete lines to our result
            lines.prepend(*chunk_lines)
          end

          # Add the remaining partial line at the beginning
          lines.unshift(partial_line) unless partial_line.empty?
        end

        line_count ? lines.last(line_count) : lines
      end
    end
  end
end
