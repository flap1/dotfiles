# -*- coding: utf-8 -*-

from xkeysnail.transform import define_timeout, define_keymap, K, Key, define_modmap, define_multipurpose_modmap

# define timeout for multipurpose_modmap
define_timeout(1)

define_modmap({
    Key.MUHENKAN: Key.ESC,
    Key.HENKAN: Key.BACKSPACE,
})

define_multipurpose_modmap(
    {Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL]},
)

