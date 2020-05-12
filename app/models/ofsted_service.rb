class OfstedService < Service
    scope :ofsted_unapproved, -> { where(approved: false) }
    scope :ofsted_pending, -> { ofsted_unapproved.joins(:snapshots).where(snapshots: { action: ['ofsted_create', 'ofsted_update'] } ) }

    scope :ofsted_pending_creates, -> { ofsted_unapproved.joins(:snapshots).where(snapshots: { action: 'ofsted_create' } ) }
    scope :ofsted_pending_updates, -> { ofsted_unapproved.joins(:snapshots).where(snapshots: { action: 'ofsted_update' } ) }
end