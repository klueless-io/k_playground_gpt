require 'zip'

class Carnivore
  def dir
    'spec/carnivore/conversations/'
  end

  def transfer_holding_conversation_to_target
    # Step 1: Read the name from the file
    file_path = File.join(dir, '000.txt')
    name = File.readlines(file_path).first.chomp.downcase.gsub(" ", "-")

    # Step 2: Get all files and determine the latest sequence number
    all_files = Dir.entries(dir)
    latest_seq = all_files.map { |file| file.split('-').first }.reject { |s| s.empty? }.map(&:to_i).max

    # Step 2.5: Check if file with this name already exists
    existing_file = all_files.detect { |file| file.include?(name) }

    if existing_file
      puts "File with name #{name} already exists: #{existing_file}"
      return "#{dir}#{existing_file}"
    end

    # Step 3: Increment the number
    new_seq = latest_seq + 1

    # Step 4: Generate new filename
    new_filename = "#{new_seq.to_s.rjust(3, '0')}-#{name}.txt"

    # Step 5: Create and write to the new file (assuming you're copying the content)
    full_path = "#{dir}#{new_filename}"
    File.write(full_path, File.read(file_path))

    puts "File #{new_filename} created successfully!"

    full_path
  end

  def archive_conversations
    zipfile_name = File.join(dir, 'conversations.zip')

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Dir.entries(dir).each do |file|
        file_path = File.join(dir, file)
        # Skip directories and the specific file 000.txt
        next if File.directory?(file_path) || file == '000.txt'
        zipfile.add(file, file_path)
      end
    end

    puts "Archived conversations to #{zipfile_name}!"
  end

  STYLE_1 = ['001', '002', '003', '004', '005', '007', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020', '021', '022', '023', '036', '037', '053', '055', '056', '057', '058', '059', '060', '061', '064', '066', '075', '076', '078', '079', '080', '081', '082', '083', '084', '085', '086', '087', '088', '089', '090', '091', '092']
  
  def process_conversations_to_json
    Dir.chdir(dir) do
      # Ensure the json subfolder exists
      Dir.mkdir('json') unless Dir.exist?('json')

      # Get all txt files except for 000.txt
      txt_files = Dir.glob('*.txt').reject { |file| file == '000.txt' }.sort

      # For each txt file...
      txt_files.each do |file_name|
        # Read its contents
        data = File.read(file_name)

        begin
          parsed_json = nil
          # Parse the content to get the JSON structure
          # parsed_json = parse_conversation_data(data)

          if STYLE_1.any? { |prefix| file_name.start_with?(prefix) }
            parsed_json = normalize1(parse_data1(data))
          else
            parsed_json = normalize2(parse_conversation_data(data))
          end
          
          if !parsed_json.nil?
            # Save the parsed data to a new JSON file in the json subfolder
            json_file_name = "json/#{File.basename(file_name, '.txt')}.json"
            File.open(json_file_name, 'w') do |f|
              f.write(JSON.pretty_generate(parsed_json))
            end
          end
        rescue => exception
          puts "Error parsing #{file_name}: #{exception}"          
        end
      end
    end
  end

  def normalize1(comments)
    reply_comments = modify_structure1(comments[1..-1])
    {
      "author" => comments[0]['author'],
      "content" => comments[0]['content'],
      "replies" => reply_comments.reject { |reply| reply['reply_by'].nil? }
    }
  end

  def modify_structure1(replies)
    replies.map do |reply|
      {
        "reply_by" => reply['content'].split("\n", 2).first,
        "content" => reply['content'].split("\n", 2).last,
        "replies" => reply.key?('replies') ? modify_structure1(reply['replies']) : []
      }
    end
  end

  def normalize2(comments)
    # return comments
    first = comments.first
    {
      "author" => first[:author],
      "content" => first[:content],
      "replies" => modify_structure2(first[:replies]).reject { |reply| reply['reply_by'] == 'Share' }
    }
  end

  def modify_structure2(replies)
    replies.map do |reply|
      # content contains \n then author is equal to the second element when spliting by \n
      # else content = content
      author = nil
      content = nil


      # I need to match using regex and content line that starts
      # with 1w, 2w, 3w etc.
      # or 1d, 2d, 3d etc.

      if reply[:content].match?(/\d{1,2}w$/)
        parts = reply[:content].split("\n", 3)
        if parts.length >= 2
          author = parts[1]
        end
        if parts.length >= 3
          content = parts[2]
        end
      elsif reply[:content].include?("\n")
        parts = reply[:content].split("\n", 3)
        if parts.length >= 2
          author = parts[1]
        end
        if parts.length >= 3
          content = parts[2]
        end
      else
        author = reply[:author]
        content = reply[:content]
      end

      {
        "reply_by" => author,
        "content" => content,
      }
    end
  end


  def parse_data1(data)
    lines = data.split("\n")
    comments = []

    while !lines.empty?
        comment = extract_comment1(lines)
        if comment
            comments << comment
        end
    end

    comments
  end

  def extract_comment1(lines)
    return nil if lines.empty?

    comment = {}
    author = lines.shift.strip

    # Check for 'Author' label
    if !lines.empty? && lines[0] == 'Author'
        comment['author_type'] = lines.shift.strip
    end

    comment['author'] = author

    # Extract content
    content = []
    while !lines.empty? && !['Reply', 'Edited', 'Share', 'Author'].any? { |keyword| lines[0].include?(keyword) }
        content << lines.shift.strip
    end
    comment['content'] = content.join("\n")

    # Extract timestamp
    if !lines.empty? && ['Reply', 'Edited', 'Share'].any? { |keyword| lines[0].include?(keyword) }
        comment['timestamp'] = lines.shift.strip
    end

    # Recursively extract replies
    replies = []
    while !lines.empty? && !lines[0].match?(/\d{1,2}w$/)
        reply = extract_comment1(lines)
        if reply
            replies << reply
        end
    end
    if !replies.empty?
        comment['replies'] = replies
    end

    comment
  end

  def parse_conversation_data(data)
    lines = data.split("\n")
    comments = []
  
    # Identify main comment
    main_author = lines.shift.strip
    main_content = []
    while lines.any? && !lines[0].match?(/^\d+ comments$/)
      main_content << lines.shift.strip
    end
    main_content = main_content.join("\n")
    
    # Skip the comment count line
    lines.shift if lines[0].match?(/^\d+ comments$/)
  
    comments << {
      author: main_author,
      content: main_content,
      replies: []
    }
  
    # Helper function to extract replies
    def extract_replies(lines)
      replies = []
      while lines.any?
        reply = {}
        reply[:author] = lines.shift.strip
        content = []
        while lines.any? && !['Reply', 'Edited', 'Share', 'Author'].include?(lines[0])
          content << lines.shift.strip
        end
        reply[:content] = content.join("\n")
        if ['Reply', 'Edited', 'Share'].include?(lines[0])
          reply[:timestamp] = lines.shift.strip
        end
        replies << reply
      end
      replies
    end
  
    comments[0][:replies] = extract_replies(lines)
    
    comments
  end
end
