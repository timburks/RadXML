;; source files
(set @m_files     (filelist "^Classes/.*.m$"))

(set @arch (list "x86_64"))
(set @cflags "-g -std=gnu99 -DDARWIN -I /usr/include/libxml2")
(set @ldflags  "-framework Foundation -lxml2")

;; framework description
(set @framework "RadXML")
(set @framework_identifier "com.radtastical.radxml")
(set @framework_creator_code "????")

(compilation-tasks)
(framework-tasks)

(task "default" => "framework")


