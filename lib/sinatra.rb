require 'rbbt'
require 'rbbt/resource'

Rbbt.claim Rbbt.www.views.public.js.nvd3.find(:lib), :proc do |dir|
  url = "https://github.com/novus/nvd3/tarball/master"

  TmpFile.with_file(nil, true, :extension => 'tar.gz') do |tar|
    Open.write(tar, Open.read(url, :mode => 'rb', :noz => true), :mode => 'wb')
    FileUtils.mkdir_p dir unless File.exists? dir
    CMD.cmd("tar xvfz '#{tar}' --directory '#{dir}' ")
    Dir.glob(File.join(dir, '*/*')).each do |file|
      FileUtils.mv(file, dir)
    end
  end
  nil
end

Rbbt.www.views.public.js.nvd3.find(:lib).produce

get '/nvd3/css' do
  content_type 'text/css', :charset => 'utf-8'
  cache_control :public, :max_age => 360000 if production?

  file = locate_sass('d3js')

  @cache_type = production? ? :synchronous : :none
  cache('css', :_template_file => file, :_send_file => true) do
    Log.debug{ "Rendering nvd3 stylesheets" }
    renderer = Sass::Engine.new(Open.read(file), :filename => file, 
                                :style => production? ? :compressed : nil, 
                                :debug_info => development? ? true : false)
    mine = renderer.render
    original = Rbbt.www.views.public.js.nvd3['nv.d3.min.css'].read
    original + mine
  end
end

get '/nvd3/js' do
  content_type 'text/javascript', :charset => 'utf-8'
  cache_control :public, :max_age => 360000 if production?

  @cache_type = production? ? :synchronous : :none
  cache('js', :_template_file => 'nvd3', :_send_file => true) do
    Log.debug{ "Compiling nvd3 javascript" }

    text = Rbbt.www.views.public.js.nvd3.lib['d3.v3.js'].read + "\n" +
      Rbbt.www.views.public.js.nvd3['nv.d3.js'].read

    text
  end
end

