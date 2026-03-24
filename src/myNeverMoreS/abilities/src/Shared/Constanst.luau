local module = {}

module["RAY_EXCLUDE_TAG"] = "RayExclude"
module.NON_STATIC_TAG = "NonStatic"
module.FIRE_MODE = {
	SEMI = "Semi",
	AUTO = "Auto",
}
module.AMMO_ATTRIBUTE = "_ammo"
module.RELOADING_ATTRIBUTE = "_reloading"
module.DAMAGE_ATTRIBUTE = "damage"
module.FIRE_MODE_ATTRIBUTE = "fireMode"
module.MAGAZINE_SIZE_ATTRIBUTE = "magazineSize"
module.RANGE_ATTRIBUTE = "range"
module.RATE_OF_FIRE_ATTRIBUTE = "rateOfFire"
module.RELOAD_TIME_ATTRIBUTE = "reloadTime"
module.RAYS_PER_SHOT_ATTRIBUTE = "raysPerShot"
module.RAY_RADIUS_ATTRIBUTE = "rayRadius"
module.SPREAD_ATTRIBUTE = "spread"
module.VIEW_MODEL_ATTRIBUTE = "viewModel"
module.RECOIL_MIN_ATTRIBUTE = "recoilMin"
module.RECOIL_MAX_ATTRIBUTE = "recoilMax"
module.UNANCHORED_IMPULSE_FORCE_ATTRIBUTE = "unanchoredImpulseForce"
module.AIM_ASSIST_RANGE_ATTRIBUTE = "aimAssistRange"
module.AIM_ASSIST_FOV_ATTRIBUTE = "aimAssistFov"
module.AIM_ASSIST_FRICTION_STRENGTH_ATTRIBUTE = "aimAssistFrictionStrength"
module.AIM_ASSIST_TRACKING_STRENGTH_ATTRIBUTE = "aimAssistTrackingStrength"
module.AIM_ASSIST_CENTERING_STRENGTH_ATTRIBUTE = "aimAssistCenteringStrength"

module.KEYBOARD_RELOAD_KEY_CODE = Enum.KeyCode.R
module.GAMEPAD_RELOAD_KEY_CODE = Enum.KeyCode.ButtonX

-- Pixel size under which a screen is considered 'small'. This is the same threshold used by the default touch UI.
module.UI_SMALL_SCREEN_THRESHOLD = 500
-- Amount to scale the UI when on a small screen
module.UI_SMALL_SCREEN_SCALE = 0.6

module.HITMARKER_SOUND_DELAY = 0.1

-- Aim assist
module.AIM_ASSIST_BIND_NAME_START = "AimAssistStart"
module.AIM_ASSIST_BIND_NAME_APPLY = "AimAssistApply"
module.AIM_ASSIST_TARGET_TAG = "Target"

module.AIM_ASSIST_DEADZONE = 0.1
module.AIM_ASSIST_INACTIVITY = 0.1
module.AIM_ASSIST_MIN_RANGE = 10

-- View model
module.VIEW_MODEL_BIND_NAME = "BlasterViewModel"
module.VIEW_MODEL_OFFSET = CFrame.new(0.9, -1.3, -1.3)
module.VIEW_MODEL_BOBBING_SPEED = 0.4
module.VIEW_MODEL_BOBBING_AMOUNT = 0.05
module.VIEW_MODEL_BOBBING_TRANSITION_SPEED = 10
module.VIEW_MODEL_RELOAD_FADE_TIME = 0.1
-- Recoil
module.RECOIL_BIND_NAME = "Recoiler"
module.RECOIL_STOP_SPEED = 10
module.RECOIL_ZOOM_RETURN_SPEED = 20
module.RECOIL_DEFAULT_FOV = 70
-- VFX
module.LASER_BEAM_VISUAL_SPEED = 200


module.dashTime = 3
module.dashDistance= 20
return module
