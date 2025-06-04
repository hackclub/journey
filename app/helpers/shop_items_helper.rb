module ShopItemsHelper
  def text_field_editable(item, field_name, display_prefix: "")
    editable(item, field_name, display_prefix, :text)
  end

  def number_field_editable(item, field_name, display_prefix: "")
    editable(item, field_name, display_prefix, :number)
  end

  def image_field_editable(item, field_name)
    editable(item, field_name, nil, :image)
  end

  private

  def editable(item, field_name, display_prefix = "", field_type)
    container_id = "item-#{item.id}-container-#{field_name}"

    style = "line-clamp-3 text-sm md:text-base 2xl:text-lg text-gray-600 break-words overflow-wrap-anywhere"
    if field_name == :name
      style = "text-2xl"
    end

    html = content_tag(:div, id: container_id, class: "item-container") do
      safe_join([
        content_tag(:div, class: "item", style: "display: flex; flex-direction: column;") do
          if field_type == :image
            tag = image_tag item.image.variant(:thumb)
          else
            tag = content_tag(:p, "#{display_prefix}#{item.public_send(field_name)}", class: style)
          end

          concat tag

          admin_tool("m-0 my-auto px-1 py-0 ml-auto leading-none") do
            button_tag "Edit #{field_name}", class: "edit text-xs"
          end
        end,

        form_with(model: item, url: shop_item_path(item), scope: :shop_item, html: { style: "display: none;" }) do |f|
          if field_type == :text
            form_field = f.text_field(field_name, class: style)
          elsif field_type == :number
            form_field = f.number_field(field_name, step: 0.01, class: style)
          elsif field_type == :image
            form_field = f.file_field(field_name, class: style)
          else
            raise NotImplementedError
          end

          safe_join([ form_field, f.submit ])
        end
      ])
    end

    js = javascript_tag <<~JS
      document.addEventListener("DOMContentLoaded", () => {
        const container = document.getElementById("#{container_id}");
        if (!container) return;

        const row  = container.querySelector(".item");
        const form = container.querySelector("form");

        container.querySelector("button.edit").onclick = () => {
          row.style.display  = "none";
          form.style.display = "block";
        };

        form.onsubmit = (e) => {
          e.preventDefault();
          const data = new FormData(form);

          fetch("#{shop_item_path(item)}", {
            method: "PATCH",
            body: data,
            headers: {
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
              "Accept": "application/json"
            },
            credentials: "same-origin"
          }).then(() => window.location.reload());
        };
      });
    JS

    safe_join([ html, js ])
  end
end
