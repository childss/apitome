module Apitome
  class Error < StandardError
  end

  class FileNotFoundError < Apitome::Error
  end

  class UndefinedGroupError < Apitome::Error
  end
end
