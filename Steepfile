D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"
  check "Gemfile"

  # library "pathname"              # Standard libraries
  # library "strong_json"           # Gems

  # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
  configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
  # configure_code_diagnostics(D::Ruby.silent)       # `silent` diagnostics setting
  # configure_code_diagnostics do |hash|             # You can setup everything yourself
  #   hash[D::Ruby::NoMethod] = :information
  # end
end

# target :test do
#   signature "sig", "sig-private"

#   check "test"

#   # library "pathname"              # Standard libraries
# end
