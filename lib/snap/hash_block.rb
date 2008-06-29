#
# Method based configuration class
# Example:
# 
#   c=HashBlock.new :app=>:my_app do
#     app :todo
#     database do
#       production do
#         host :localhost
#         database :todo_production
#         username ''
#         password ''
#       end
#       development do
#         
#       end
#       test do
#         
#       end
#     end
#   end
#   c.to_hash
#

module Snap
  
  class HashBlock
    
    # the_private_instance_methods=["Array", "Float", "Integer", "Pathname", "String", "`", "abort", "at_exit", "autoload", "autoload?", "binding", "block_given?", "callcc", "caller", "catch", "chomp", "chomp!", "chop", "chop!", "e_as", "e_sh", "e_sn", "e_snp", "e_url", "eval", "exec", "exit", "exit!", "fail", "fork", "format", "getc", "gets", "global_variables", "gsub", "gsub!", "htmlize", "initialize_copy", "iterator?", "lambda", "load", "local_variables", "loop", "method_missing", "open", "p", "print", "printf", "proc", "putc", "puts", "raise", "rand", "readline", "readlines", "remove_instance_variable", "require", "scan", "select", "set_trace_func", "singleton_method_added", "singleton_method_removed", "singleton_method_undefined", "sleep", "split", "sprintf", "srand", "sub", "sub!", "syscall", "system", "test", "throw", "trace_var", "trap", "untrace_var", "warn"]
    
    #
    #
    #
    (private_instance_methods + instance_methods).each { |m| undef_method m unless (m =~ /^__/) or
  ['class', 'instance_eval', 'initialize', 'block_given?', 'puts', 'p', 'printf', 'print'].include?(m) }
    
    #
    #
    #
    def initialize(init_data=nil, &block)
      @d = init_data || {}
      instance_eval(&block) if block_given?
    end
    
    #
    #
    #
    def to_hash; @d; end
    
    #
    #
    #
    def self.load_from_file(file)
      self.new.instance_eval File.read(file)
    end
    
    protected
    
    #
    #
    #
    def method_missing(method, data=nil, &block)
      @d[method] = data
      return @d[method] = self.class.new(data, &block).to_hash if
  data.nil?
      @d
    end
    
  end
  
end