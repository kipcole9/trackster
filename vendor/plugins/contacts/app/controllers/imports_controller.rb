class ImportsController < TracksterResources
  unloadable
  MAX_ONLINE_IMPORT_SIZE    = 50_000
  
  def create
    path, file_size, options = file_from_params(params[:import])
    importer = Contacts::Import.new(current_account, current_user)
    if file_size < MAX_ONLINE_IMPORT_SIZE
      importer.import(path, options)
      flash[:notice] = "Imported #{importer.records} records in about #{(importer.ended_at - importer.started_at).to_i} seconds with #{importer.errors.count} messages."
    else
      importer.send_later(:import, path, options)
      flash[:notice] = "Your import will be processed in the background."
    end
    redirect_back_or_default
  end


private

  def file_from_params(params)
    options = {}
    file                    = params[:source_file]
    size                    = file.size
    options[:description]   = params[:description]
    options[:original_file] = File.basename(file.original_filename)
    path                    = "#{Trackster::Config.shared_directory}/#{options[:original_file]}"    
    File.open(path, "wb") { |f| f.write(file.read) }
    return path, size, options
  end    
end
