# -*- coding: utf-8 -*-
#
# Copyright 2013 whiteleaf. All rights reserved.
#

module Device::Ibooks
  PHYSICAL_SUPPORT = false
  VOLUME_NAME = nil
  DOCUMENTS_PATH_LIST = nil
  EBOOK_FILE_EXT = ".epub"
  NAME = "iBooks"
  DISPLAY_NAME = "iBooks"

  IBOOKS_CONTAINER_DIR = "~/Library/Containers/com.apple.BKAgentService/Data/Documents/iBooks/Books"

  #
  # iBooks用に設定を強制設定する
  #
  def hook_change_settings(&original_func)
    @@__already_exec_change_settings ||= false
    return if @@__already_exec_change_settings
    force_change_settings_function({
      "force.enable_half_indent_bracket" => false,
      "force.enable_add_date_to_title" => false,    # タイトルを変えてもiBooksに反映されないため
    })
    @@__ibooks_container_dir = File.expand_path(IBOOKS_CONTAINER_DIR)
    unless File.exists?(@@__ibooks_container_dir)
      error "iBooksの管理フォルダが見つかりませんでした。" \
            "MacOSX Mavericks以降のiBooksのみ管理に対応しています"
      @@__ibooks_container_dir = nil
    end
    @@__already_exec_change_settings = true
  end

  #
  # EPUBへ変換したあとiBooksが管理しているディレクトリに展開する
  #
  def hook_convert_txt_to_ebook_file(&original_func)
    ebook_file_path = original_func.call
    return ebook_file_path unless @@__ibooks_container_dir
    epubdir_path = get_epubdir_path_in_ibooks_container
    if epubdir_path && File.exists?(epubdir_path)
      extract_epub(ebook_file_path, epubdir_path)
      puts "iBooksに登録してあるEPUBを更新しました"
    else
      epubdir_path = watch_ibooks_container(ebook_file_path)
      if epubdir_path
        regist_epubdir_path_to_setting(epubdir_path)
        puts "iBooksへの登録を確認しました"
      else
        error "EPUBの展開後のフォルダが見つかりませんでした。" \
              "iBooksがインストールされているか確認して下さい"
      end
    end
    ebook_file_path
  end

  def get_epubdir_path_in_ibooks_container
    list = LocalSetting.get["ibooks_epubdir_path_list"]
    if list[@id]
      list[@id]
    else
      nil
    end
  end

  def extract_epub(ebook_file_path, epubdir_path)
    require "zip"
    Zip.on_exists_proc = true
    Zip::File.open(ebook_file_path) do |zip_file|
      zip_file.each do |entry|
        extract_path = File.join(epubdir_path, entry.name)
        FileUtils.mkdir_p(File.dirname(extract_path))
        entry.extract(extract_path)
      end
    end
  end

  def watch_ibooks_container(ebook_file_path)
    just_before_list = get_ibooks_containing_epub_list
    unless esystem(%!open "#{path}"!)
      error "EPUBが開けませんでした。EPUBファイルがiBooksに関連付けられているか確認して下さい"
      return nil
    end
    limit = 15
    found_path = nil
    while limit > 0
      sleep(1)
      just_after_list = get_ibooks_containing_epub_list
      differ = just_after_list - just_before_list
      if differ.length == 1
        found_path = differ[0]
        break
      end
      limit -= 1
    end
    found_path
  end

  def get_ibooks_containing_epub_list
    Dir.glob("#{@@__ibooks_container_dir}/*.epub/")
  end

  def regist_epubdir_path_to_setting(path)
    list = LocalSetting.get["ibooks_epubdir_path_list"]
    list[@id] = path
    LocalSetting.get.save_settings("ibooks_epubdir_path_list")
  end
end
