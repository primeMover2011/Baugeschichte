#include "clusterproxy.h"
#include "housetrailimages.h"

ClusterProxy::ClusterProxy()
{

}

ClusterProxy::~ClusterProxy()
{

}


bool ClusterProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    bool ret( false );
        if ( this->sourceModel() != nullptr )
        {
            auto index = this->sourceModel()->index( source_row, 0, source_parent );
            if ( index.isValid() )
            {
                auto valueRole = index.data( HousetrailModel::HousetrailRoles::CoordinateRole );
                if ( valueRole.isValid() )
                {
                    bool ok( false );
                    auto value = valueRole.toInt( &ok );
                    if ( ok )
                    {
                        if ( ( value % 2 ) == 0 )
                        {
                            ret = true;
                        }
                    }
                }
            }
        }
        return ret;
}
