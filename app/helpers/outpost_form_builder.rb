class OutpostFormBuilder < ActionView::Helpers::FormBuilder
  def text_area_wysiwyg(method, options = {})
    options[:class] = [options[:class], 'wysiwyg-simple'].compact.join(' ') if Setting.feature_wysiwyg
    @template.text_area(
      @object_name, method, objectify_options(options)
    )
  end
end