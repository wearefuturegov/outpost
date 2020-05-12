class OfstedService < Service

    scope :ofsted_pending, -> { OfstedService.joins(:snapshots).where(snapshots: { action: ['ofsted_create', 'ofsted_update'] } ) }

end

