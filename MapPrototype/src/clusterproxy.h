#ifndef CLUSTERPROXY_H
#define CLUSTERPROXY_H
#include <QSortFilterProxyModel>

class ClusterProxy : public QSortFilterProxyModel
{
public:

    Q_OBJECT
  public:
      ClusterProxy();
      virtual ~ClusterProxy();

      bool filterAcceptsRow( int source_row, const QModelIndex& source_parent ) const override;
signals:

public slots:
};

#endif // CLUSTERPROXY_H
