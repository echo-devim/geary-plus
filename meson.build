project('geary', [ 'vala', 'c' ],
  version: '3.35.0',
  license: 'LGPL2.1+',
  meson_version: '>= 0.50',
)

# Build-time configuration options
enable_valadoc = get_option('valadoc')
install_contractor_file = get_option('contractor')
iso_3166_xml = get_option('iso_3166_xml')
iso_639_xml = get_option('iso_639_xml')
poodle = get_option('poodle')
reference_tracking = get_option('ref_tracking')

# Build type
if get_option('profile') == 'development'
  profile = '.Devel'
  name_suffix = ' (Development)'
elif get_option('profile') == 'beta'
  profile = '.Beta'
  name_suffix = ' (Beta)'
else
  profile = ''
  name_suffix = ''
endif

# Configurable install dirs
geary_prefix = get_option('prefix')
bin_dir = join_paths(geary_prefix, get_option('bindir'))
data_dir = join_paths(geary_prefix, get_option('datadir'))
lib_dir = join_paths(geary_prefix, get_option('libdir'))
locale_dir = join_paths(geary_prefix, get_option('localedir'))

# Source dirs
metadata_dir = join_paths(meson.source_root(), 'bindings', 'metadata')
po_dir = join_paths(meson.source_root(), 'po')
vapi_dir = join_paths(meson.source_root(), 'bindings', 'vapi')

# Compiler configuration
add_project_arguments([
    # Make sure Meson can find custom VAPIs
    '--vapidir', vapi_dir,
    '--metadatadir', metadata_dir,
  ],
  language: 'vala'
)
cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

#
# Required libraries and other dependencies
#

target_glib = '2.60.4'
target_gtk = '3.24.7'
target_webkit = '2.24'

# Primary deps
glib = dependency('glib-2.0', version: '>=' + target_glib)
gmime = dependency('gmime-2.6', version: '>= 2.6.17')
gtk = dependency('gtk+-3.0', version: '>=' + target_gtk)
sqlite = dependency('sqlite3', version: '>= 3.12')
webkit2gtk = dependency('webkit2gtk-4.0', version: '>=' + target_webkit)

# Secondary deps - keep sorted alphabetically
# We need appdata.its from appstream-glib:
# https://gitlab.gnome.org/GNOME/geary/issues/439
appstream_glib = dependency('appstream-glib', version: '>=0.7.10')
enchant = dependency('enchant-2', version: '>=2.1', required: false) # see below
folks = dependency('folks', version: '>=0.11')
gck = dependency('gck-1')
gcr = dependency('gcr-3', version: '>= 3.10.1')
gdk = dependency('gdk-3.0', version: '>=' + target_gtk)
gee = dependency('gee-0.8', version: '>= 0.8.5')
gio = dependency('gio-2.0', version: '>=' + target_glib)
goa = dependency('goa-1.0')
gspell = dependency('gspell-1')
gthread = dependency('gthread-2.0', version: '>=' + target_glib)
iso_codes = dependency('iso-codes')
javascriptcoregtk = dependency('javascriptcoregtk-4.0', version: '>=' + target_webkit)
json_glib = dependency('json-glib-1.0', version: '>= 1.0')
libhandy = dependency('libhandy-0.0', version: '>= 0.0.9', required: false)
libmath = cc.find_library('m')
libpeas = dependency('libpeas-1.0', version: '>= 1.22.0')
libsecret = dependency('libsecret-1', version: '>= 0.11')
libsoup = dependency('libsoup-2.4', version: '>= 2.48')
libunwind_dep = dependency(
  'libunwind', version: '>= 1.1', required: not get_option('libunwind_optional')
)
libunwind_generic_dep = dependency(
  'libunwind-generic', version: '>= 1.1', required: not get_option('libunwind_optional')
)
libxml = dependency('libxml-2.0', version: '>= 2.7.8')
libytnef = dependency('libytnef', version: '>= 1.9.3', required: get_option('tnef-support'))
posix = valac.find_library('posix')
webkit2gtk_web_extension = dependency('webkit2gtk-web-extension-4.0', version: '>=' + target_webkit)

# Can currently use either Enchant 1 or 2
if not enchant.found()
  enchant = dependency('enchant', version: '>=1.6')
endif

# Handy isn't necessarily packaged by distros, so fall back to a
# subproject until it is.
if not libhandy.found()
  libhandy_subproj = subproject(
    'libhandy',
    default_options: [
      'examples=false',
      'glade_catalog=disabled',
      'tests=false',
    ]
  )

  libhandy = declare_dependency(
    dependencies: [
      libhandy_subproj.get_variable('libhandy_dep'),
      libhandy_subproj.get_variable('libhandy_vapi'),
    ]
  )
endif

# Libunwind system dependencies above ensures appropriate versions,
# but this declared depencency is what we actually build against so we
# can include the custom VAPI correctly. We need to add unwind_lib to
# the search path for these so Flatpak builds can find the C lib.
if libunwind_dep.found()
  unwind_lib = libunwind_dep.get_pkgconfig_variable('libdir')
  libunwind = declare_dependency(
     dependencies: [
       valac.find_library('libunwind', dirs: [vapi_dir, unwind_lib]),
       cc.find_library('libunwind', dirs: unwind_lib),
       cc.find_library('libunwind-generic', dirs: unwind_lib)
     ],
   )
endif

# Optional dependencies
appstream_util = find_program('appstream-util', required: false)
desktop_file_validate = find_program('desktop-file-validate', required: false)
libmessagingmenu_dep = dependency('messaging-menu', version: '>= 12.10', required: false)
libunity = dependency('unity', version: '>= 5.12.0', required: false)

#
# Internal build configuration
#

# Build variables
geary_id = 'org.gnome.Geary@0@'.format(profile)
geary_version = meson.project_version()
revno = run_command('build-aux/git_version.py').stdout().strip()

gnome = import('gnome')
i18n = import('i18n')

# Static install dirs
dbus_services_dir = join_paths(data_dir, 'dbus-1', 'services')
plugins_dir = join_paths(lib_dir, 'geary', 'plugins')
web_extensions_dir = join_paths(lib_dir, 'geary', 'web-extensions')

# Ensure SQLite was built correctly
if not cc.has_header_symbol('sqlite3.h', 'SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER', dependencies: sqlite)
  error('SQLite3 is missing FTS3 tokenizer support. Please compile it with -DSQLITE_ENABLE_FTS3.\n'
        + 'See https://bugzilla.gnome.org/show_bug.cgi?id=763203 for details.')
endif

#
# Build glue
#

if enable_valadoc
  valadoc = find_program('valadoc')
endif

# Language detection
iso_codes_dir = join_paths(iso_codes.get_pkgconfig_variable('prefix'), 'share', 'xml', 'iso-codes')
if iso_639_xml == ''
  iso_639_xml = join_paths(iso_codes_dir, 'iso_639.xml')
endif
if iso_3166_xml == ''
  iso_3166_xml = join_paths(iso_codes_dir, 'iso_3166.xml')
endif
files(iso_639_xml, iso_3166_xml) # Check to make sure these exist

# Post-install scripts
meson.add_install_script(join_paths('build-aux', 'post_install.py'))

# Subfolders
subdir('desktop')
subdir('help')
subdir('icons')
subdir('po')
subdir('sql')
subdir('ui')
subdir('src')
subdir('test')
