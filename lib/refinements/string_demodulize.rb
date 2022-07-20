module StringDemodulize
  refine String do
    def demodulize
      split("::").last
    end
  end
end
