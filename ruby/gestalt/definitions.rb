module Ohcount
	module Gestalt


    ############################# Platforms #############################
    #                                                                   #
    # Platforms is used in the most general sense of the word. We don't #
    # discriminate between OS-platforms and a lightweight framework -   #
    # any type of dependency is fair game.                              #
    #                                                                   #
    # What guides what we add here is mostly for internal Ohloh         #
    # purposes.                                                         #
    #                                                                   #
    #####################################################################

    define_platform 'POSIX' do
      # gnu_lib && generic
      c_headers 'pthread.h', 'xstrtol.h', 'xreadlink.h', 'fatal-signal.h', 'diacrit.h', 'syslog.h', 'sys/stat.h'

      # autoconf means m4 (unix macro processor)
      language :autoconf
    end

    define_platform 'Win32' do
      c_headers 'windows.h'
      c_keywords 'WM_PAINT', 'ReleaseDC', 'WndProc', :min => 2
    end

    define_platform 'VisualBasic' do
      language :visualbasic, :min_percent => 5
    end

    define_platform 'Ruby' do
      language :ruby, :min_percent => 15
    end

    define_platform 'Rails' do
      _and do
        gestalt(:platform, 'Ruby')
        ruby_keywords("RAILS_ROOT")
      end
    end

    define_platform 'Java' do
      language :java, :min_percent => 15
    end

    define_platform 'Javascript' do
      language :javascript, :min_percent => 20
    end

    define_platform 'JQuery' do
      filenames 'jquery-\d.\d.\d.min.js$'
    end

		define_platform 'mootools' do
			filenames '\bmootools-\d(\.\d)*(-core)?(-..)?\.js$'
		end

		define_platform 'prototype' do
			filenames '\bprototype(-\d+(\.\d)+)?.js$'
		end

		define_platform 'yui' do
			_or do
				filenames '\byahoo-min\.js$'
				html_keywords '\byahoo-min\.js\b'
			end
		end

		define_platform 'dojo' do
			_or do
				filenames '\bdojo\.js$'
				html_keywords '\bdojo\.xd\.js\b'
			end
		end

		define_platform 'flash' do
			_or do
				language :actionscript, :min_percent => 1
				_and do
					gestalt(:platform, 'Java')
					java_import /^(flash)\..+/
				end
			end
		end

		define_platform 'flex' do
			_or do
				language :mxml, :min_percent => 1
				_and do
					gestalt(:platform, 'Java')
					java_import /^(mx)\..+/
				end
			end
		end

    define_platform 'XWindows' do
      c_headers 'Xlib.h', 'X11\/xpm.h', 'X11/Xlib.h'
    end

    define_platform 'Mac' do
      # apple events
      c_keywords 'AppleEvent', 'AEBuildAppleEvent'

      # plist is a mac thing, right?
      filenames '\.plist'
    end

    define_platform 'PHP' do
      language :php, :min_percent => 15
    end

    define_platform 'WxWidgets' do
      c_headers 'wx/window.h'
    end

		define_platform 'ZendFramework' do
      _and do
        gestalt(:platform, 'PHP')
        php_keywords('Zend_Controller_Action')
      end
		end

		define_platform 'Symfony' do
			_and do
        gestalt(:platform, 'PHP')
        php_keywords('sfCore', 'sfConfig')
      end
    end

		define_platform 'Pear' do
      _and do
        gestalt(:platform, 'PHP')
        _or do
          filenames('\bpackage\.xml(\.tpl)?$')
          xml_keywords('pear\.php\.net/dtd/package\-2\.0')
        end
      end
		end

		define_platform 'Moodle' do
			_and do
				gestalt(:platform, 'PHP')
				php_keywords("moodle")
      end
		end

    define_platform 'SQL' do
      language :sql
    end

    define_platform 'MySQL' do
      php_keywords('mysql_connect')
    end

    define_platform 'PostgreSQL' do
      php_keywords('pg_connect')
    end

		define_platform 'Python' do
			language :python, :min_percent => 15
		end

		define_platform 'Perl' do
			language :perl, :min_percent => 20
		end

		define_platform 'Scripting' do
			gestalt(:platform, 'Javascript')
			gestalt(:platform, 'Perl')
			gestalt(:platform, 'PHP')
			gestalt(:platform, 'Python')
			gestalt(:platform, 'Ruby')
		end

		define_platform 'CakePHP' do
			_and do
        gestalt(:platform, 'PHP')
				php_keywords('CAKE_CORE_INCLUDE_PATH')
      end
		end

		define_platform 'KDE' do
			c_headers 'KDEInit.h', 'kdeversion.h'
		end

		define_platform 'GTK' do
			c_keywords 'gtk_init', 'gtk_main', 'gtk_window_new', 'GtkWidget'
		end

		define_platform 'Drupal' do
			_and do
				gestalt(:platform, 'PHP')
				_or do
					php_keywords('drupal_set_message')
					php_keywords('drupal_render')
					php_keywords('Drupal', :min => 3)
        end
      end
		end

		define_platform 'MSDos' do
			c_keywords '__MSDOS__', 'MSDOS', :min => 2
    end

    define_platform 'EclipsePlatform' do
      java_import /org\.eclipse\./
    end


    ############################### Tools ###############################

    define_tool 'VisualStudio' do
      filenames '\.(sln|vcproj|vsproj|csproj|vbproj|vbp)$'
    end

    define_tool 'Eclipse' do
      filenames '\.(project|classpath)$'
    end

    define_tool 'NetBeans' do
      filenames '\bnbplatform\b'
      filenames '\.nbm$'
    end

    ############################ ARM ###################################

		define_platform 'arm' do
			c_headers "arm4.h", "arm3.h"
			c_keywords "arm_int32_t", "arm_start_application", "__arm__"
			make_keywords '\b\-mabi\b','\barmcc\b'
			java_keywords '\barm\-eabi'
			assembler_keywords '\bsmlal\b', '\bsmulw\b', '\borrs\b'
			gestalt(:platform, 'arm_neon')
			java_import /org\.opengroup\.arm/
		end

    ########################## ARM NEON ################################

    define_platform 'arm_neon' do
      assembler_keywords '\bvld1\.\d\d\b', '\bvld1\.\d\d\b','\bvmov\b','\bvmov\.u8\b'
      make_keywords '\bneon\b','\bNEON\b'
    end

		############################ ATOM ##################################
		# Atom is hard to detect, since it implements x86 instruction set

		define_platform 'sse3_atom_flag' do
			make_keywords 'SSE3_ATOM'
		end

		define_platform 'xL_flag' do
			make_keywords '\bxL\b', '\/QxL\b'
		end

		define_platform 'atom' do
			gestalt(:platform, 'sse3_atom_flag')
			gestalt(:platform, 'xL_flag')
		end

		########################## COMPILER ################################
		define_platform 'intel_compiler' do
			make_keywords '\bicc\b'
		end

		define_platform 'gcc' do
			make_keywords '\bgcc\b'
		end

    ########################### MOBLIN #################################

		define_platform 'clutter' do
			c_keywords "ClutterActor", '\bclutter_actor_', "ClutterStage", "ClutterBehavior", "clutter_main"
			csharp_keywords "ClutterActor", '\bclutter_actor_', "ClutterStage", "ClutterBehavior", "clutter_main"
			perl_keywords "Clutter::Behavior", "Clutter::Actor", "Clutter::Stage"
			java_keywords "ClutterActor", "ClutterStage", "ClutterShader"
			ruby_keywords "Clutter::Actor", "Clutter::Stage", "Clutter::Shader", "Clutter::Cairo"
		end

		define_platform 'moblin' do
			c_keywords '\"org\.moblin\.', 'MOBLIN_NETBOOK_SYSTEM_TRAY_H', 'org_Moblin_', '\"org\.Moblin\.', "url=\"http://moblin.org\">http://moblin.org</ulink>"
			make_keywords "org\.moblin\.", "moblin-netbook"
			filenames 'moblin-netbook-system-tray.h$'
		end

		define_platform 'nbtk' do
			c_keywords '\bnbtk_[a-z]+', '\bNbtk[A-Z][a-z]+'
			java_keywords '\bnbtk_[a-z]+', '\bNbtk[A-Z][a-z]+'
			ruby_keywords '\bnbtk_[a-z]+', '\bNbtk[A-Z][a-z]+'
			filenames 'nbtk\/nbtk.h'
		end

		define_platform 'moblin_all' do
			gestalt(:platform, 'clutter')
			gestalt(:platform, 'moblin')
			gestalt(:platform, 'nbtk')
		end

    ########################### ANDROID #################################

		define_platform 'android' do
			java_import /\bandroid\./
		end

    ############################ iPhone #################################

		define_platform 'iPhone' do
			objective_c_keywords '\bUIApplicationMain', '\bUIWindow', '\bUIView', '\bUIResponder'
		end

    ############################ Maemo #################################

		define_platform 'hildon' do
			c_keywords '\bHildonFile', '\bhildon_file_', '\bHildonProgram', '\bHildonWindow', '\bhildon_window'
			c_headers 'hildon/hildon.h'
			_and do
				python_keywords '\bimport hildon'
				python_keywords '\bimport gtk'
			end
		end
		define_platform 'maemo' do
			gestalt(:platform, 'hildon')
		end

		define_platform 'MID_combined' do
			gestalt(:platform, 'clutter')
			gestalt(:platform, 'nbtk')
			gestalt(:platform, 'moblin')
			gestalt(:platform, 'maemo')
			gestalt(:platform, 'android')
			gestalt(:platform, 'iPhone')
		end


    ############################ Windows CE ############################
		define_platform 'windows_ce_incomplete' do
			csharp_keywords 'Microsoft\.WindowsCE', 'Microsoft\.WindowsMobile'
			vb_keywords 'Microsoft\.WindowsCE', 'Microsoft\.WindowsMobile'
		end

		######################### Native Code ##############################
		define_platform 'native_code' do
			language :c, :min_percent => 5
			language :cpp, :min_percent => 5
			language :cncpp, :min_percent => 5
			language :assembly, :min_percent => 5
			language :d, :min_percent => 5
			language :fortran, :min_percent => 5
			language :haskell, :min_percent => 5
			language :cobol, :min_percent => 5
		end
	end
end
