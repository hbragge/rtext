$:.unshift File.join(File.dirname(__FILE__),"..","lib")

require 'test/unit'
require 'rgen/ecore/ecore'
require 'rgen/template_language'
require 'rgen/metamodel_builder'
require 'rgen/model_builder'
require 'rgen/environment'
require 'rgen/instantiator/reference_resolver'
require 'rgen/fragment/fragmented_model'
require 'rtext/instantiator'
require 'rtext/language'
require 'rtext/default_loader'

class TemplateContainerTest < Test::Unit::TestCase
  
  TPL_DIR = File.dirname(__FILE__)+"/templates"
  OUT_DIR = File.dirname(__FILE__)+"/"
  
  module StatemachineMM
    extend RGen::MetamodelBuilder::ModuleExtension
    class Statemachine < RGen::MetamodelBuilder::MMBase
    end
    class Transition < RGen::MetamodelBuilder::MMBase
      has_attr 'condition'
    end
    class State < RGen::MetamodelBuilder::MMBase
      has_attr 'name'
      contains_one 'transition', Transition, 'state'
    end
    Transition.has_one 'targetState', State
    Statemachine.contains_many 'states', State, 'statemachine'
  end

  def test_model
    tc = RGen::TemplateLanguage::DirectoryTemplateContainer.new(StatemachineMM, OUT_DIR)
    tc.load(TPL_DIR)
    File.delete(OUT_DIR+"/fsm.c") if File.exists? OUT_DIR+"/fsm.c"

    mm = StatemachineMM
    env = RGen::Environment.new
    lang = RText::Language.new(mm.ecore, 
      :root_classes => mm.ecore.eAllClasses.select{|c| c.name == "Statemachine" },
      :unlabled_arguments => lambda {|c| ["name"] },
      :unquoted_arguments => lambda {|c| ["name"] },
      :line_number_attribute => "line_number",
      :fragment_ref_attribute => "fragment_ref"
    )

    model = RGen::Fragment::FragmentedModel.new(:env => RGen::Environment.new)
    loader = RText::DefaultLoader.new(lang, model, :file_provider => lambda { [File.expand_path("fsm.sta")] })
    loader.load

    tc.expand('root::Root', :for => model.fragments[0].root_elements)
    result = expected = ""
    File.open(OUT_DIR+"/fsm.c") {|f| result = f.read}
    File.open(OUT_DIR+"/fsm.c.expected") {|f| expected = f.read}
    assert_equal expected, result
  end
  
end
