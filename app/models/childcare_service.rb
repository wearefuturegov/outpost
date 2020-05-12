class ChildcareService < Service

    scope :ofsted_pending, -> { ChildcareService.joins(:snapshots).where(snapshots: { action: ['ofsted_create', 'ofsted_update'] } ) }

end

