{{mb_script module=files script=file_category}}

<button class="button new" onclick="FilesCategory.edit('0');">{{tr}}CFilesCategory-title-create{{/tr}}</button>

<table class="main">
  <tr>
    <td style="width: 50%;" id="list_file_category"></td>
    <td style="width: 50%;" id="edit_file_category"></td>
  </tr>
</table>

<script>
  FilesCategory.loadList();
  FilesCategory.edit('{{$category_id}}');
</script>