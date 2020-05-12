class OfstedService < Service
    scope :ofsted_pending, -> { OfstedService.joins(:snapshots).where(snapshots: { action: ['ofsted_create', 'ofsted_update'] } ) }

    scope :ofsted_pending_creates, -> { OfstedService.joins(:snapshots).where(snapshots: { action: 'ofsted_create' } ) }
    scope :ofsted_pending_updates, -> { OfstedService.joins(:snapshots).where(snapshots: { action: 'ofsted_update' } ) }
end