# Apex SpectraOverdrive Bridge — Project Workup

## 0.3.0 implementation

- Frozen shader ABI 1.0 for intensity, color, four bands, beat, blackout, strobe, group ID, and show time.
- Ordinary Unity and VRChat-safe `_Udon` global contracts.
- Broadcast/exact groups, normalized band weighting, tint/emission helpers, and neutral defaults.
- Optional safety vector that caps intensity, disables strobe, or caps strobe amplitude while preserving 0.2 drivers when inactive.

See `Documentation/ABI.md` for the stable field contract.

## Next work

- Reference driver in SpectraOverdrive.
- Device validation of Udon writes and safety behavior.
